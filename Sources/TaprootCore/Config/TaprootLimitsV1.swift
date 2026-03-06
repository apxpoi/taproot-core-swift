import Foundation

// Global financial constraints used by Taproot.
// These limits protect against overflow, corruption, and unrealistic precision in fixed-point arithmetic.

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

    // Portfolio-wide maximum total value in base currency units.
    //
    // Chosen to keep headroom above current top individual wealth levels while
    // preserving deterministic offline behavior.
    //
    // Value: 10,000,000,000,000 (10 trillion)
    public static let maxTotalAssetsValue = Decimal(10_000_000_000_000)

    // Character limits for money string handling.
    //
    // Processing limit protects parsing/normalization paths from oversized input.
    // Display limit keeps rendered values compact and consistent in UI surfaces.
    public static let maxMoneyProcessingCharacters = 32
    public static let maxMoneyDisplayCharacters = 24

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
    public static let minPBKDF2Iterations = 1
    public static let maxPBKDF2Iterations = 1_000_000
    public static let defaultPBKDF2Iterations = 100_000
}
