import Foundation

public enum VaultValidationError: Error, Equatable {
    case exceedsMaxTotalAssetsValue(actual: Decimal, maximum: Decimal)
    case snapshotsMustBeSortedByTimestamp
    case snapshotTimestampsMustBeUnique
    case snapshotBaseCurrencyMismatch
    case cashFlowsMustBeSortedByTimestamp
    case cashFlowReferencesUnknownAccount
}

public extension Vault {
    func validate() throws {
        let accountIDs = Set(accounts.map(\.id))

        for account in accounts {
            try account.institution.validate()
            for asset in account.assets {
                try asset.validate()
            }
        }

        var lastSnapshotTimestamp: Int64?
        var seenSnapshotTimestamps = Set<Int64>()
        for snapshot in snapshots {
            try snapshot.validate()

            guard snapshot.baseCurrency == baseCurrency else {
                throw VaultValidationError.snapshotBaseCurrencyMismatch
            }

            if !seenSnapshotTimestamps.insert(snapshot.capturedAtUnixMs).inserted {
                throw VaultValidationError.snapshotTimestampsMustBeUnique
            }

            if let lastSnapshotTimestamp, snapshot.capturedAtUnixMs < lastSnapshotTimestamp {
                throw VaultValidationError.snapshotsMustBeSortedByTimestamp
            }
            lastSnapshotTimestamp = snapshot.capturedAtUnixMs
        }

        var lastCashFlowTimestamp: Int64?
        for cashFlow in cashFlows {
            try cashFlow.validate()

            if let accountID = cashFlow.accountID, !accountIDs.contains(accountID) {
                throw VaultValidationError.cashFlowReferencesUnknownAccount
            }

            if let lastCashFlowTimestamp, cashFlow.occurredAtUnixMs < lastCashFlowTimestamp {
                throw VaultValidationError.cashFlowsMustBeSortedByTimestamp
            }
            lastCashFlowTimestamp = cashFlow.occurredAtUnixMs
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
