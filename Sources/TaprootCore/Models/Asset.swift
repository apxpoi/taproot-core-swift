import Foundation

public struct Asset: Codable, Identifiable, Hashable {
    public var id: UUID

    /// Logical asset category key (for example: "cash", "securities", "crypto").
    public var type: String

    // Total value stored as a fixed-point integer.
    // Example: value = 123456, currencyScale = 2 => 1234.56 USD.
    public var value: Int64
    public var currency: String
    public var currencyScale: Int

    // Quantity stored as a fixed-point integer.
    // Example: quantity = 52310000, quantityScale = 6 => 52.31.
    public var quantity: Int64
    public var quantityScale: Int

    // Stable unit identifier for quantity measurement.
    // Example: "share", "gram", "custom:tola", "unit".
    public var unitType: String

    /// Human-readable symbol for the asset (e.g. "QQQ", "AAPL").
    public var symbol: String

    /// Last valuation timestamp in Unix milliseconds.
    /// Required for market assets (for example: securities, crypto).
    public var valuationAtUnixMs: Int64?

    public var note: String

    public init(
        id: UUID = UUID(),
        type: String,
        value: Int64,
        currency: String,
        currencyScale: Int,
        quantity: Int64 = 1,
        quantityScale: Int = 0,
        unitType: String = AssetUnitType.unit.id,
        symbol: String = "",
        valuationAtUnixMs: Int64? = nil,
        note: String = ""
    ) {
        self.id = id

        self.type = type

        self.value = value
        self.currency = currency
        self.currencyScale = currencyScale

        self.quantity = quantity
        self.quantityScale = quantityScale

        self.unitType = unitType

        self.symbol = symbol

        self.valuationAtUnixMs = valuationAtUnixMs

        self.note = note
    }

    public init(
        id: UUID = UUID(),
        type: AssetType,
        value: Int64,
        currency: String,
        currencyScale: Int,
        quantity: Int64 = 1,
        quantityScale: Int = 0,
        unitType: AssetUnitType? = nil,
        symbol: String = "",
        valuationAtUnixMs: Int64? = nil,
        note: String = ""
    ) {
        self.init(
            id: id,
            type: type.id,
            value: value,
            currency: currency,
            currencyScale: currencyScale,
            quantity: quantity,
            quantityScale: quantityScale,
            unitType: (unitType ?? type.defaultUnitType).id,
            symbol: symbol,
            valuationAtUnixMs: valuationAtUnixMs,
            note: note
        )
    }
}

public extension Asset {
    var assetTypeDefinition: AssetType? {
        return AssetType(rawValue: type)
    }

    var normalizedUnitTypeID: String {
        let trimmedIdentifier = unitType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedIdentifier.isEmpty else {
            return assetTypeDefinition?.defaultUnitType.id ?? ""
        }

        return trimmedIdentifier
    }

    var unitTypeDefinition: AssetUnitType? {
        return AssetUnitType(id: normalizedUnitTypeID)
    }

    var hasCustomUnitType: Bool {
        return AssetUnitType.isCustomIdentifier(normalizedUnitTypeID)
    }

    /// Returns the decimal value derived from `value` and `currencyScale` (for example, 1234.56).
    var decimalValue: Decimal {
        return Decimal(value) / FixedPointMath.pow10(currencyScale)
    }

    /// Returns the decimal quantity derived from `quantity` and `quantityScale` (for example, 52.31).
    var decimalQuantity: Decimal {
        return Decimal(quantity) / FixedPointMath.pow10(quantityScale)
    }
}
