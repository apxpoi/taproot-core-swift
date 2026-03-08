import Foundation

public struct Vault: Codable {
    public var version: Int
    public var createdAt: Date
    public var baseCurrency: String
    public var accounts: [Account]
    public var snapshots: [PortfolioSnapshot]
    public var cashFlows: [CashFlowEvent]

    public init(
        version: Int = 1,
        createdAt: Date = Date(),
        baseCurrency: String = "USD",
        accounts: [Account] = [],
        snapshots: [PortfolioSnapshot] = [],
        cashFlows: [CashFlowEvent] = []
    ) {
        self.version = version
        self.createdAt = createdAt
        self.baseCurrency = baseCurrency
        self.accounts = accounts
        self.snapshots = snapshots
        self.cashFlows = cashFlows
    }
}
