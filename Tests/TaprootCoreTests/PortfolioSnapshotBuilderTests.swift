@testable import TaprootCore
import XCTest

final class PortfolioSnapshotBuilderTests: XCTestCase {
    func testBuildSnapshotConvertsAssetsAndIncludesUsedFXRatesOnly() throws {
        let capturedAtUnixMs: Int64 = 1_772_064_000_000
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    displayName: "Main",
                    assets: [
                        Asset(
                            type: AssetType.cash.id,
                            value: 10_000,
                            currency: "USD",
                            currencyScale: 2
                        ),
                        Asset(
                            type: AssetType.commodities.id,
                            value: 780_000,
                            currency: "HKD",
                            currencyScale: 2
                        ),
                        Asset(
                            type: AssetType.securities.id,
                            value: 50_000,
                            currency: "USD",
                            currencyScale: 2,
                            quantity: 10,
                            quantityScale: 0,
                            unitType: AssetUnitType.share.id,
                            symbol: "TAP",
                            valuationAtUnixMs: capturedAtUnixMs
                        ),
                    ],
                    institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
                ),
            ]
        )

        let snapshot = try vault.buildSnapshot(
            capturedAtUnixMs: capturedAtUnixMs,
            totalValueScale: 2,
            fxRates: [
                SnapshotFXRate(
                    fromCurrency: "HKD",
                    toCurrency: "USD",
                    rate: 1_280_000,
                    rateScale: 7,
                    quotedAtUnixMs: capturedAtUnixMs
                ),
                SnapshotFXRate(
                    fromCurrency: "EUR",
                    toCurrency: "USD",
                    rate: 1_080_000,
                    rateScale: 6,
                    quotedAtUnixMs: capturedAtUnixMs
                ),
            ],
            note: "Month-end generated"
        )

        XCTAssertEqual(snapshot.baseCurrency, "USD")
        XCTAssertEqual(snapshot.totalValueScale, 2)
        XCTAssertEqual(snapshot.totalValue, 159_840) // 100.00 + 998.40 + 500.00 = 1,598.40
        XCTAssertEqual(snapshot.note, "Month-end generated")

        XCTAssertEqual(snapshot.groupValues.count, 3)
        XCTAssertEqual(snapshot.groupValues.first(where: { $0.group == .liquid })?.value, 10_000)
        XCTAssertEqual(snapshot.groupValues.first(where: { $0.group == .market })?.value, 50_000)
        XCTAssertEqual(snapshot.groupValues.first(where: { $0.group == .tangible })?.value, 99_840)

        XCTAssertEqual(snapshot.fxRates.count, 1)
        XCTAssertEqual(snapshot.fxRates.first?.fromCurrency, "HKD")
        XCTAssertEqual(snapshot.fxRates.first?.toCurrency, "USD")
    }

    func testBuildSnapshotRejectsMissingFXRate() {
        let capturedAtUnixMs: Int64 = 1_772_064_000_000
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    displayName: "Main",
                    assets: [
                        Asset(
                            type: AssetType.commodities.id,
                            value: 100_000,
                            currency: "HKD",
                            currencyScale: 2
                        ),
                    ],
                    institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
                ),
            ]
        )

        XCTAssertThrowsError(
            try vault.buildSnapshot(
                capturedAtUnixMs: capturedAtUnixMs,
                fxRates: []
            )
        ) { error in
            guard case PortfolioSnapshotBuilderError.missingFXRate(let fromCurrency, let toCurrency) = error else {
                return XCTFail("Expected missingFXRate, got: \(error)")
            }

            XCTAssertEqual(fromCurrency, "HKD")
            XCTAssertEqual(toCurrency, "USD")
        }
    }

    func testBuildSnapshotRejectsDuplicateFXRatePair() {
        let capturedAtUnixMs: Int64 = 1_772_064_000_000
        let vault = Vault(baseCurrency: "USD")

        XCTAssertThrowsError(
            try vault.buildSnapshot(
                capturedAtUnixMs: capturedAtUnixMs,
                fxRates: [
                    SnapshotFXRate(
                        fromCurrency: "HKD",
                        toCurrency: "USD",
                        rate: 1_280_000,
                        rateScale: 7,
                        quotedAtUnixMs: capturedAtUnixMs
                    ),
                    SnapshotFXRate(
                        fromCurrency: "HKD",
                        toCurrency: "USD",
                        rate: 1_281_000,
                        rateScale: 7,
                        quotedAtUnixMs: capturedAtUnixMs
                    ),
                ]
            )
        ) { error in
            guard case PortfolioSnapshotBuilderError.duplicateFXRatePair(let fromCurrency, let toCurrency) = error else {
                return XCTFail("Expected duplicateFXRatePair, got: \(error)")
            }

            XCTAssertEqual(fromCurrency, "HKD")
            XCTAssertEqual(toCurrency, "USD")
        }
    }

    func testBuildSnapshotRejectsFXRateTimestampAfterSnapshot() {
        let capturedAtUnixMs: Int64 = 1_772_064_000_000
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    displayName: "Main",
                    assets: [
                        Asset(
                            type: AssetType.commodities.id,
                            value: 100_000,
                            currency: "HKD",
                            currencyScale: 2
                        ),
                    ],
                    institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
                ),
            ]
        )

        XCTAssertThrowsError(
            try vault.buildSnapshot(
                capturedAtUnixMs: capturedAtUnixMs,
                fxRates: [
                    SnapshotFXRate(
                        fromCurrency: "HKD",
                        toCurrency: "USD",
                        rate: 1_280_000,
                        rateScale: 7,
                        quotedAtUnixMs: capturedAtUnixMs + 1
                    ),
                ]
            )
        ) { error in
            guard case PortfolioSnapshotBuilderError.fxRateTimestampAfterSnapshot(_, let quotedAtUnixMs, let timestamp) = error else {
                return XCTFail("Expected fxRateTimestampAfterSnapshot, got: \(error)")
            }

            XCTAssertEqual(quotedAtUnixMs, capturedAtUnixMs + 1)
            XCTAssertEqual(timestamp, capturedAtUnixMs)
        }
    }

    func testBuildSnapshotRejectsMarketAssetValuationAfterSnapshot() {
        let capturedAtUnixMs: Int64 = 1_772_064_000_000
        let assetID = UUID()
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    displayName: "Brokerage",
                    assets: [
                        Asset(
                            id: assetID,
                            type: AssetType.securities.id,
                            value: 10_000,
                            currency: "USD",
                            currencyScale: 2,
                            quantity: 1,
                            quantityScale: 0,
                            unitType: AssetUnitType.share.id,
                            symbol: "TAP",
                            valuationAtUnixMs: capturedAtUnixMs + 1
                        ),
                    ],
                    institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
                ),
            ]
        )

        XCTAssertThrowsError(
            try vault.buildSnapshot(
                capturedAtUnixMs: capturedAtUnixMs,
                fxRates: []
            )
        ) { error in
            guard case PortfolioSnapshotBuilderError.marketAssetValuationAfterSnapshot(let returnedAssetID, let valuationAtUnixMs, let timestamp) = error else {
                return XCTFail("Expected marketAssetValuationAfterSnapshot, got: \(error)")
            }

            XCTAssertEqual(returnedAssetID, assetID)
            XCTAssertEqual(valuationAtUnixMs, capturedAtUnixMs + 1)
            XCTAssertEqual(timestamp, capturedAtUnixMs)
        }
    }
}
