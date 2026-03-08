import Foundation

public enum PortfolioSnapshotBuilderError: Error {
    case invalidCapturedAtTimestamp
    case invalidTotalValueScale
    case invalidFXRateTargetCurrency(expected: String, actual: String)
    case duplicateFXRatePair(fromCurrency: String, toCurrency: String)
    case missingFXRate(fromCurrency: String, toCurrency: String)
    case fxRateTimestampAfterSnapshot(fromCurrency: String, quotedAtUnixMs: Int64, capturedAtUnixMs: Int64)
    case marketAssetValuationAfterSnapshot(assetID: UUID, valuationAtUnixMs: Int64, capturedAtUnixMs: Int64)
    case valueOverflow
}

public enum PortfolioSnapshotBuilder {
    public static func build(
        from vault: Vault,
        capturedAtUnixMs: Int64,
        totalValueScale: Int = 2,
        fxRates: [SnapshotFXRate],
        note: String = ""
    ) throws -> PortfolioSnapshot {
        guard capturedAtUnixMs > 0 else {
            throw PortfolioSnapshotBuilderError.invalidCapturedAtTimestamp
        }

        guard
            totalValueScale >= TaprootLimitsV1.minCurrencyScale,
            totalValueScale <= TaprootLimitsV1.maxCurrencyScale
        else {
            throw PortfolioSnapshotBuilderError.invalidTotalValueScale
        }

        let fxRateMap = try buildFXRateMap(
            fxRates: fxRates,
            baseCurrency: vault.baseCurrency
        )

        var groupedTotals: [AssetTypeDisplayGroup: Decimal] = [:]
        var usedFXRates: [String: SnapshotFXRate] = [:]

        for account in vault.accounts {
            for asset in account.assets {
                try asset.validate()

                if
                    let assetType = AssetType(rawValue: asset.type),
                    assetType.requiresValuationTimestamp,
                    let valuationAtUnixMs = asset.valuationAtUnixMs,
                    valuationAtUnixMs > capturedAtUnixMs
                {
                    throw PortfolioSnapshotBuilderError.marketAssetValuationAfterSnapshot(
                        assetID: asset.id,
                        valuationAtUnixMs: valuationAtUnixMs,
                        capturedAtUnixMs: capturedAtUnixMs
                    )
                }

                let valueInBaseCurrency = try convertToBaseCurrency(
                    asset: asset,
                    baseCurrency: vault.baseCurrency,
                    capturedAtUnixMs: capturedAtUnixMs,
                    fxRateMap: fxRateMap
                )

                if asset.currency != vault.baseCurrency {
                    let key = fxRateKey(fromCurrency: asset.currency, toCurrency: vault.baseCurrency)
                    if let fxRate = fxRateMap[key] {
                        usedFXRates[key] = fxRate
                    }
                }

                let displayGroup = AssetType(rawValue: asset.type)?.displayGroup ?? AssetType.other.displayGroup
                groupedTotals[displayGroup, default: .zero] += valueInBaseCurrency
            }
        }

        var groupValues = [PortfolioSnapshotGroupValue]()
        var totalValue: Int64 = 0

        for group in AssetTypeDisplayGroup.allCases {
            guard let groupedTotal = groupedTotals[group], groupedTotal != .zero else {
                continue
            }

            let fixedPointValue = try toFixedPointInt64(groupedTotal, scale: totalValueScale)
            let (newTotalValue, overflow) = totalValue.addingReportingOverflow(fixedPointValue)
            guard !overflow else {
                throw PortfolioSnapshotBuilderError.valueOverflow
            }
            totalValue = newTotalValue

            groupValues.append(
                PortfolioSnapshotGroupValue(
                    group: group,
                    value: fixedPointValue
                )
            )
        }

        let usedFXRateTable = usedFXRates.values.sorted {
            if $0.fromCurrency == $1.fromCurrency {
                return $0.toCurrency < $1.toCurrency
            }
            return $0.fromCurrency < $1.fromCurrency
        }

        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: capturedAtUnixMs,
            baseCurrency: vault.baseCurrency,
            totalValue: totalValue,
            totalValueScale: totalValueScale,
            groupValues: groupValues,
            fxRates: usedFXRateTable,
            note: note
        )
        try snapshot.validate()
        return snapshot
    }

    private static func convertToBaseCurrency(
        asset: Asset,
        baseCurrency: String,
        capturedAtUnixMs: Int64,
        fxRateMap: [String: SnapshotFXRate]
    ) throws -> Decimal {
        guard asset.currency != baseCurrency else {
            return asset.decimalValue
        }

        let key = fxRateKey(fromCurrency: asset.currency, toCurrency: baseCurrency)
        guard let fxRate = fxRateMap[key] else {
            throw PortfolioSnapshotBuilderError.missingFXRate(
                fromCurrency: asset.currency,
                toCurrency: baseCurrency
            )
        }

        guard fxRate.quotedAtUnixMs <= capturedAtUnixMs else {
            throw PortfolioSnapshotBuilderError.fxRateTimestampAfterSnapshot(
                fromCurrency: asset.currency,
                quotedAtUnixMs: fxRate.quotedAtUnixMs,
                capturedAtUnixMs: capturedAtUnixMs
            )
        }

        return asset.decimalValue * fxRate.decimalRate
    }

    private static func buildFXRateMap(
        fxRates: [SnapshotFXRate],
        baseCurrency: String
    ) throws -> [String: SnapshotFXRate] {
        var fxRateMap: [String: SnapshotFXRate] = [:]

        for fxRate in fxRates {
            guard fxRate.toCurrency == baseCurrency else {
                throw PortfolioSnapshotBuilderError.invalidFXRateTargetCurrency(
                    expected: baseCurrency,
                    actual: fxRate.toCurrency
                )
            }

            let key = fxRateKey(fromCurrency: fxRate.fromCurrency, toCurrency: fxRate.toCurrency)
            if fxRateMap[key] != nil {
                throw PortfolioSnapshotBuilderError.duplicateFXRatePair(
                    fromCurrency: fxRate.fromCurrency,
                    toCurrency: fxRate.toCurrency
                )
            }

            fxRateMap[key] = fxRate
        }

        return fxRateMap
    }

    private static func fxRateKey(fromCurrency: String, toCurrency: String) -> String {
        "\(fromCurrency)->\(toCurrency)"
    }

    private static func toFixedPointInt64(_ value: Decimal, scale: Int) throws -> Int64 {
        var scaled = value * FixedPointMath.pow10(scale)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &scaled, 0, .bankers)

        guard rounded <= Decimal(Int64.max), rounded >= Decimal(Int64.min) else {
            throw PortfolioSnapshotBuilderError.valueOverflow
        }

        let number = NSDecimalNumber(decimal: rounded)
        guard number != NSDecimalNumber.notANumber else {
            throw PortfolioSnapshotBuilderError.valueOverflow
        }
        return number.int64Value
    }
}

public extension Vault {
    func buildSnapshot(
        capturedAtUnixMs: Int64,
        totalValueScale: Int = 2,
        fxRates: [SnapshotFXRate],
        note: String = ""
    ) throws -> PortfolioSnapshot {
        try PortfolioSnapshotBuilder.build(
            from: self,
            capturedAtUnixMs: capturedAtUnixMs,
            totalValueScale: totalValueScale,
            fxRates: fxRates,
            note: note
        )
    }
}
