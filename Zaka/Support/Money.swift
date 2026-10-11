import Foundation

/// Rand formatting, fixed to `R1,234.56` regardless of device region.
enum Money {
    static let symbol = "R"

    /// Grouping and decimal separators are pinned so amounts read the same
    /// everywhere; only the currency itself is opinionated here.
    private static let style = Locale(identifier: "en_US")

    /// `R1,234.56` — for individual amounts.
    static func string(_ value: Double) -> String {
        symbol + value.formatted(
            .number.precision(.fractionLength(2)).locale(style)
        )
    }

    /// `R1,235` — for totals, where cents are noise.
    static func rounded(_ value: Double) -> String {
        symbol + value.formatted(
            .number.precision(.fractionLength(0)).locale(style)
        )
    }
}
