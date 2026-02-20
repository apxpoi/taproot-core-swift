import Foundation

public struct Asset: Codable, Identifiable {
    public var id: UUID

    /// e.g. the unique id of "cash", "stock", "crypto", "gold", "real_estate"
    public var type: String

    // Total value stored as fixed-point integer
    // Example: value = 123456, currencyScale = 2 => 1234.56 USD
    public var value: Int64
    public var currency: String
    public var currencyScale: Int

    // Quantity of units
    // Example: quantity = 52310000, quantityScale = 6 => 52.31 BTC
    public var quantity: Int64
    public var quantityScale: Int

    /// e.g. "kg", "unit", "property", "cash"
    public var unitType: String
}

public extension Asset {
    /// Returns decimal value representation (e.g. 1234.56)
    var decimalValue: Decimal {
        return Decimal(value) / FixedPointMath.pow10(currencyScale)
    }

    /// Returns decimal quantity representation (e.g. 52.31)
    var decimalQuantity: Decimal {
        return Decimal(quantity) / FixedPointMath.pow10(quantityScale)
    }
}
