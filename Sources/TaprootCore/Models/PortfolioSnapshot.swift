import Foundation

public struct PortfolioSnapshot: Codable, Identifiable, Hashable {
    public var id: UUID
    public var capturedAtUnixMs: Int64
    public var baseCurrency: String
    public var totalValue: Int64
    public var totalValueScale: Int
    public var groupValues: [PortfolioSnapshotGroupValue]
    public var fxRates: [SnapshotFXRate]
    public var note: String

    public init(
        id: UUID = UUID(),
        capturedAtUnixMs: Int64,
        baseCurrency: String,
        totalValue: Int64,
        totalValueScale: Int,
        groupValues: [PortfolioSnapshotGroupValue] = [],
        fxRates: [SnapshotFXRate] = [],
        note: String = ""
    ) {
        self.id = id
        self.capturedAtUnixMs = capturedAtUnixMs
        self.baseCurrency = baseCurrency
        self.totalValue = totalValue
        self.totalValueScale = totalValueScale
        self.groupValues = groupValues
        self.fxRates = fxRates
        self.note = note
    }
}

public extension PortfolioSnapshot {
    var decimalTotalValue: Decimal {
        Decimal(totalValue) / FixedPointMath.pow10(totalValueScale)
    }
}

public struct PortfolioSnapshotGroupValue: Codable, Hashable {
    public var group: AssetTypeDisplayGroup
    public var value: Int64

    public init(
        group: AssetTypeDisplayGroup,
        value: Int64
    ) {
        self.group = group
        self.value = value
    }
}

public extension PortfolioSnapshotGroupValue {
    func decimalValue(scale: Int) -> Decimal {
        Decimal(value) / FixedPointMath.pow10(scale)
    }
}

public struct SnapshotFXRate: Codable, Hashable {
    public var fromCurrency: String
    public var toCurrency: String
    public var rate: Int64
    public var rateScale: Int
    public var quotedAtUnixMs: Int64

    public init(
        fromCurrency: String,
        toCurrency: String,
        rate: Int64,
        rateScale: Int,
        quotedAtUnixMs: Int64
    ) {
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.rate = rate
        self.rateScale = rateScale
        self.quotedAtUnixMs = quotedAtUnixMs
    }
}

public extension SnapshotFXRate {
    var decimalRate: Decimal {
        Decimal(rate) / FixedPointMath.pow10(rateScale)
    }
}
