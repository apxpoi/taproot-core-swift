import Foundation

public enum CashFlowEventValidationError: Error {
    case invalidOccurredAtTimestamp
    case invalidAmount
    case invalidCurrencyCode
    case invalidCurrencyScale
}

public extension CashFlowEvent {
    func validate() throws {
        guard occurredAtUnixMs > 0 else {
            throw CashFlowEventValidationError.invalidOccurredAtTimestamp
        }

        guard amount > 0 else {
            throw CashFlowEventValidationError.invalidAmount
        }

        let currencyPattern = /^[A-Z]{3}$/
        guard currency.wholeMatch(of: currencyPattern) != nil else {
            throw CashFlowEventValidationError.invalidCurrencyCode
        }

        guard
            currencyScale >= TaprootLimitsV1.minCurrencyScale,
            currencyScale <= TaprootLimitsV1.maxCurrencyScale
        else {
            throw CashFlowEventValidationError.invalidCurrencyScale
        }
    }
}
