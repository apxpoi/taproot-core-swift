import Foundation

public enum AssetValidationError: Error {
    case invalidCurrencyScale
    case invalidQuantityScale
    case invalidValuationTimestamp
    case missingValuationTimestampForMarketAsset
}

public extension Asset {
    func validate() throws {
        guard currencyScale >= TaprootLimitsV1.minCurrencyScale, currencyScale <= TaprootLimitsV1.maxCurrencyScale else {
            throw AssetValidationError.invalidCurrencyScale
        }

        guard quantityScale >= TaprootLimitsV1.minQuantityScale, quantityScale <= TaprootLimitsV1.maxQuantityScale else {
            throw AssetValidationError.invalidQuantityScale
        }

        if let valuationAtUnixMs, valuationAtUnixMs <= 0 {
            throw AssetValidationError.invalidValuationTimestamp
        }

        if let assetType = AssetType(rawValue: type), assetType.requiresValuationTimestamp, valuationAtUnixMs == nil {
            throw AssetValidationError.missingValuationTimestampForMarketAsset
        }
    }
}
