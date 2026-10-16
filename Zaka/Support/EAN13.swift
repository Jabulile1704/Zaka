import Foundation

nonisolated enum EAN13 {
    static let moduleCount = 95

    private static let leftOdd = [
        "0001101", "0011001", "0010011", "0111101", "0100011",
        "0110001", "0101111", "0111011", "0110111", "0001011"
    ]

    private static let leftEven = [
        "0100111", "0110011", "0011011", "0100001", "0011101",
        "0111001", "0000101", "0010001", "0001001", "0010111"
    ]

    private static let right = [
        "1110010", "1100110", "1101100", "1000010", "1011100",
        "1001110", "1010000", "1000100", "1001000", "1110100"
    ]

    private static let parity = [
        "LLLLLL", "LLGLGG", "LLGGLG", "LLGGGL", "LGLLGG",
        "LGGLLG", "LGGGLL", "LGLGLG", "LGLGGL", "LGGLGL"
    ]

    static func checkDigit(for first12: [Int]) -> Int? {
        guard first12.count == 12, first12.allSatisfy({ (0...9).contains($0) }) else {
            return nil
        }
        let sum = first12.enumerated().reduce(0) { total, pair in
            total + pair.element * (pair.offset.isMultiple(of: 2) ? 1 : 3)
        }
        return (10 - sum % 10) % 10
    }

    static func isValid(_ text: String) -> Bool {
        guard let digits = digits(of: text), digits.count == 13 else { return false }
        return checkDigit(for: Array(digits.prefix(12))) == digits[12]
    }

    static func modules(for text: String) -> [Bool]? {
        guard let digits = digits(of: text), digits.count == 13 else { return nil }
        guard checkDigit(for: Array(digits.prefix(12))) == digits[12] else { return nil }

        var bits = "101"

        let pattern = Array(parity[digits[0]])
        for (index, digit) in digits[1...6].enumerated() {
            bits += pattern[index] == "L" ? leftOdd[digit] : leftEven[digit]
        }

        bits += "01010"

        for digit in digits[7...12] {
            bits += right[digit]
        }

        bits += "101"

        guard bits.count == moduleCount else { return nil }
        return bits.map { $0 == "1" }
    }

    private static func digits(of text: String) -> [Int]? {
        let cleaned = text.filter(\.isNumber)
        guard !cleaned.isEmpty else { return nil }
        return cleaned.compactMap { $0.wholeNumberValue }
    }
}
