import Foundation

public enum VaultValidationError: Error, Equatable {
    case exceedsMaxTotalAssetsValue(actual: Decimal, maximum: Decimal)
}

public extension Vault {
    func validate() throws {
        // Assumes asset values have already been normalized by the caller into a
        // comparable monetary unit for portfolio-level checks.
        let portfolioTotal = accounts
            .flatMap(\.assets)
            .reduce(Decimal.zero) { $0 + $1.decimalValue }

        guard portfolioTotal <= TaprootLimitsV1.maxTotalAssetsValue else {
            throw VaultValidationError.exceedsMaxTotalAssetsValue(
                actual: portfolioTotal,
                maximum: TaprootLimitsV1.maxTotalAssetsValue
            )
        }
    }
}
