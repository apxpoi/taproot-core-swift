import Foundation

public enum AssetValidationError: Error {
    case invalidCurrencyScale
    case invalidQuantityScale
}

public extension Asset {
    func validate() throws {
        guard currencyScale >= TaprootLimitsV1.minCurrencyScale, currencyScale <= TaprootLimitsV1.maxCurrencyScale else {
            throw AssetValidationError.invalidCurrencyScale
        }

        guard quantityScale >= TaprootLimitsV1.minQuantityScale, quantityScale <= TaprootLimitsV1.maxQuantityScale else {
            throw AssetValidationError.invalidQuantityScale
        }
    }
}
