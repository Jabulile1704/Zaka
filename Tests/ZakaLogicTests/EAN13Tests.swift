import XCTest
@testable import ZakaLogic

final class EAN13Tests: XCTestCase {
    private let leftOdd = ["0001101","0011001","0010011","0111101","0100011","0110001","0101111","0111011","0110111","0001011"]
    private let leftEven = ["0100111","0110011","0011011","0100001","0011101","0111001","0000101","0010001","0001001","0010111"]
    private let rightTable = ["1110010","1100110","1101100","1000010","1011100","1001110","1010000","1000100","1001000","1110100"]
    private let parityTable = ["LLLLLL","LLGLGG","LLGGLG","LLGGGL","LGLLGG","LGGLLG","LGGGLL","LGLGLG","LGLGGL","LGGLGL"]

    func testCheckDigits() {
        XCTAssertEqual(EAN13.checkDigit(for: digits("400638133393")), 1)
        XCTAssertEqual(EAN13.checkDigit(for: digits("590123412345")), 7)
        XCTAssertEqual(EAN13.checkDigit(for: digits("978020137962")), 4)
        XCTAssertEqual(EAN13.checkDigit(for: digits("600108700161")), 8)
    }

    func testCheckDigitRejectsWrongLength() {
        XCTAssertNil(EAN13.checkDigit(for: digits("12345")))
    }

    func testValidity() {
        XCTAssertTrue(EAN13.isValid("4006381333931"))
        XCTAssertTrue(EAN13.isValid("5901 2341 23457"))
        XCTAssertFalse(EAN13.isValid("5901234123451"))
        XCTAssertFalse(EAN13.isValid("12345"))
    }

    func testEncodeDecodeRoundTrip() throws {
        for code in ["4006381333931", "5901234123457", "9780201379624", "6001087001618", "0000000000000"] {
            let modules = try XCTUnwrap(EAN13.modules(for: code), "\(code) should encode")
            XCTAssertEqual(modules.count, EAN13.moduleCount)
            XCTAssertEqual(decode(modules), code, "\(code) should survive a round trip")
        }
    }

    func testGuardPatterns() throws {
        let modules = try XCTUnwrap(EAN13.modules(for: "5901234123457"))
        let bits = modules.map { $0 ? "1" : "0" }.joined()
        let chars = Array(bits)
        XCTAssertEqual(String(chars[0..<3]), "101")
        XCTAssertEqual(String(chars[45..<50]), "01010")
        XCTAssertEqual(String(chars[92..<95]), "101")
    }

    func testInvalidCodeProducesNoBarcode() {
        XCTAssertNil(EAN13.modules(for: "5901234123451"))
        XCTAssertNil(EAN13.modules(for: "not a barcode"))
    }

    // MARK: - Helpers

    private func digits(_ text: String) -> [Int] {
        text.compactMap(\.wholeNumberValue)
    }

    /// Decodes independently of the encoder, so a shared mistake cannot pass.
    private func decode(_ modules: [Bool]) -> String? {
        guard modules.count == 95 else { return nil }
        let chars = Array(modules.map { $0 ? "1" : "0" }.joined())
        func slice(_ lower: Int, _ upper: Int) -> String { String(chars[lower..<upper]) }

        guard slice(0, 3) == "101", slice(45, 50) == "01010", slice(92, 95) == "101" else {
            return nil
        }

        var parity = ""
        var body: [Int] = []
        for index in 0..<6 {
            let chunk = slice(3 + index * 7, 10 + index * 7)
            if let digit = leftOdd.firstIndex(of: chunk) {
                parity += "L"
                body.append(digit)
            } else if let digit = leftEven.firstIndex(of: chunk) {
                parity += "G"
                body.append(digit)
            } else {
                return nil
            }
        }
        guard let first = parityTable.firstIndex(of: parity) else { return nil }

        var tail: [Int] = []
        for index in 0..<6 {
            let chunk = slice(50 + index * 7, 57 + index * 7)
            guard let digit = rightTable.firstIndex(of: chunk) else { return nil }
            tail.append(digit)
        }
        return ([first] + body + tail).map(String.init).joined()
    }
}
