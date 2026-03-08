import Foundation

public enum CashFlowType: String, Codable, CaseIterable, Identifiable, Hashable {
    case contribution
    case withdrawal

    public var id: String { rawValue }
}

public struct CashFlowEvent: Codable, Identifiable, Hashable {
    public var id: UUID
    public var occurredAtUnixMs: Int64
    public var type: CashFlowType
    public var amount: Int64
    public var currency: String
    public var currencyScale: Int
    public var accountID: UUID?
    public var note: String

    public init(
        id: UUID = UUID(),
        occurredAtUnixMs: Int64,
        type: CashFlowType,
        amount: Int64,
        currency: String,
        currencyScale: Int,
        accountID: UUID? = nil,
        note: String = ""
    ) {
        self.id = id
        self.occurredAtUnixMs = occurredAtUnixMs
        self.type = type
        self.amount = amount
        self.currency = currency
        self.currencyScale = currencyScale
        self.accountID = accountID
        self.note = note
    }
}

public extension CashFlowEvent {
    var decimalAmount: Decimal {
        Decimal(amount) / FixedPointMath.pow10(currencyScale)
    }
}
