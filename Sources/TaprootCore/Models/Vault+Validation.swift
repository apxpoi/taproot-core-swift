import Foundation

public enum VaultValidationError: Error, Equatable {
    case exceedsMaxTotalAssetsValue(actual: Decimal, maximum: Decimal)
}

public extension Vault {
    func validate() throws {
        for account in accounts {
            try account.institution.validate()
            for asset in account.assets {
                try asset.validate()
            }
        }
    }

    func validatePortfolioTotal(baseCurrencyTotal: Decimal) throws {
        guard baseCurrencyTotal <= TaprootLimitsV1.maxTotalAssetsValue else {
            throw VaultValidationError.exceedsMaxTotalAssetsValue(
                actual: baseCurrencyTotal,
                maximum: TaprootLimitsV1.maxTotalAssetsValue
            )
        }
    }
}
