import Foundation

public enum FixedPointMath {
    /// Returns the maximum safe decimal value for a given scale
    ///
    /// Formula:
    /// Int64.max / (10 ^ scale)
    public static func maxSafeDecimalValue(for scale: Int) -> Decimal {
        return Decimal(Int64.max) / pow10(scale)
    }

    /// Helper to compute base^scale safety
    public static func pow10(_ scale: Int) -> Decimal {
        var result = Decimal(1)

        for _ in 0 ..< scale {
            result *= 10
        }

        return result
    }
}
