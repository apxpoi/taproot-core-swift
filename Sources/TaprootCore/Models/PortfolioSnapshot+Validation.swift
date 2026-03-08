import Foundation

public enum PortfolioSnapshotValidationError: Error {
    case invalidCapturedAtTimestamp
    case invalidBaseCurrency
    case invalidTotalValueScale
    case duplicateGroupValue
    case groupValuesDoNotMatchTotal
    case invalidFXRateCurrencyCode
    case invalidFXRateCurrencyPair
    case invalidFXRateTargetCurrency
    case invalidFXRateValue
    case invalidFXRateScale
    case invalidFXRateTimestamp
    case fxRateTimestampAfterSnapshot
    case duplicateFXRatePair
}

public extension PortfolioSnapshot {
    func validate() throws {
        guard capturedAtUnixMs > 0 else {
            throw PortfolioSnapshotValidationError.invalidCapturedAtTimestamp
        }

        let currencyPattern = /^[A-Z]{3}$/
        guard baseCurrency.wholeMatch(of: currencyPattern) != nil else {
            throw PortfolioSnapshotValidationError.invalidBaseCurrency
        }

        guard
            totalValueScale >= TaprootLimitsV1.minCurrencyScale,
            totalValueScale <= TaprootLimitsV1.maxCurrencyScale
        else {
            throw PortfolioSnapshotValidationError.invalidTotalValueScale
        }

        var seenGroups = Set<AssetTypeDisplayGroup>()
        for groupValue in groupValues {
            if !seenGroups.insert(groupValue.group).inserted {
                throw PortfolioSnapshotValidationError.duplicateGroupValue
            }
        }

        if !groupValues.isEmpty {
            let groupedTotal = groupValues.reduce(Decimal.zero) { partial, groupValue in
                partial + Decimal(groupValue.value)
            }

            guard groupedTotal == Decimal(totalValue) else {
                throw PortfolioSnapshotValidationError.groupValuesDoNotMatchTotal
            }
        }

        var seenFXRatePairs = Set<String>()
        for fxRate in fxRates {
            guard
                fxRate.fromCurrency.wholeMatch(of: currencyPattern) != nil,
                fxRate.toCurrency.wholeMatch(of: currencyPattern) != nil
            else {
                throw PortfolioSnapshotValidationError.invalidFXRateCurrencyCode
            }

            guard fxRate.fromCurrency != fxRate.toCurrency else {
                throw PortfolioSnapshotValidationError.invalidFXRateCurrencyPair
            }

            guard fxRate.toCurrency == baseCurrency else {
                throw PortfolioSnapshotValidationError.invalidFXRateTargetCurrency
            }

            guard fxRate.rate > 0 else {
                throw PortfolioSnapshotValidationError.invalidFXRateValue
            }

            guard
                fxRate.rateScale >= TaprootLimitsV1.minQuantityScale,
                fxRate.rateScale <= TaprootLimitsV1.maxQuantityScale
            else {
                throw PortfolioSnapshotValidationError.invalidFXRateScale
            }

            guard fxRate.quotedAtUnixMs > 0 else {
                throw PortfolioSnapshotValidationError.invalidFXRateTimestamp
            }

            guard fxRate.quotedAtUnixMs <= capturedAtUnixMs else {
                throw PortfolioSnapshotValidationError.fxRateTimestampAfterSnapshot
            }

            let pairKey = "\(fxRate.fromCurrency)->\(fxRate.toCurrency)"
            if !seenFXRatePairs.insert(pairKey).inserted {
                throw PortfolioSnapshotValidationError.duplicateFXRatePair
            }
        }
    }
}
