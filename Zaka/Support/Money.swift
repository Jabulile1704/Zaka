import Foundation

enum Money {
    static let symbol = "R"

    private static let style = Locale(identifier: "en_US")

    static func string(_ value: Double) -> String {
        symbol + value.formatted(
            .number.precision(.fractionLength(2)).locale(style)
        )
    }

    static func rounded(_ value: Double) -> String {
        symbol + value.formatted(
            .number.precision(.fractionLength(0)).locale(style)
        )
    }

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
