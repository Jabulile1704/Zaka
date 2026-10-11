import Foundation

/// Rand formatting and input parsing, fixed to `R1,234.56` regardless of
/// device region.
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

    /// Turns keypad input into an amount.
    ///
    /// The decimal pad shows whichever separator the device region prefers —
    /// `,` in South Africa, `.` in the US — so both are accepted. The
    /// right-most separator is the decimal point when it is followed by one or
    /// two digits; otherwise every separator is read as grouping. That makes
    /// `45,50` and `45.50` both 45.5, while `1,234` stays 1234.
    static func parse(_ text: String) -> Double? {
        let cleaned = text.filter { $0.isNumber || $0 == "." || $0 == "," }
        guard !cleaned.isEmpty else { return nil }

        var whole = cleaned
        var fraction = ""

        if let separator = cleaned.lastIndex(where: { $0 == "." || $0 == "," }) {
            let tail = cleaned[cleaned.index(after: separator)...]
            if (1...2).contains(tail.count), tail.allSatisfy(\.isNumber) {
                whole = String(cleaned[..<separator])
                fraction = String(tail)
            }
        }

        let digits = whole.filter(\.isNumber)
        guard !(digits.isEmpty && fraction.isEmpty) else { return nil }

        return Double("\(digits.isEmpty ? "0" : digits).\(fraction.isEmpty ? "0" : fraction)")
    }
}
