import Foundation

// Global financial constraints used by Taproot.
// These limits protect again overflow, corruption, and unrealistic precision in flexed-point arithmetic.

public enum TaprootLimitsV1 {
    // Currency decimal precision limit.
    //
    // Rationale:
    // - Fiat currencies: 0-3 decimals
    // - Stable coins: up to 6
    // - FX internal precision: up to 8-9
    //
    // Upper bound chosen to:
    // - Maintain large maximum representable wealth
    // - Avoid Int64 overflow after scaling
    //
    // With scale = 9:
    // max value = 9,223,372,036.854775807

    public static let maxCurrencyScale = 9
    public static let minCurrencyScale = 0

    // Asset quantity precision limit.
    //
    // Rationale:
    // - BTC: 8 decimals
    // - ETH: 18 decimals
    //
    // 18 is industry standard for maximum.
    //
    // NOTE: Increasing beyond 18 dramatically reduce max representable quantity.
    public static let maxQuantityScale = 18
    public static let minQuantityScale = 0

    /// Maximum safe signed 64-bit integer value.
    /// Provided for clarity when computing bounds.
    public static let maxInt64: Int64 = .max

    /// Default PBKDF2 iteration count for password derivation.
    ///
    /// Tradeoff:
    /// - higher = more secure
    /// - lower = better performance on mobile
    ///
    /// Can be adjusted in future versions.
    public static let defaultPBKDF2Iterations = 100_000
}
