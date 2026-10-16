import XCTest
@testable import ZakaLogic

final class MoneyTests: XCTestCase {
    func testDotAndCommaBothMeanDecimalPoint() {
        XCTAssertEqual(Money.parse("45.50"), 45.50)
        XCTAssertEqual(Money.parse("45,50"), 45.50)
    }

    func testGroupingIsNotMistakenForDecimals() {
        XCTAssertEqual(Money.parse("1,234"), 1234)
        XCTAssertEqual(Money.parse("1,234.56"), 1234.56)
        XCTAssertEqual(Money.parse("1.234,56"), 1234.56)
        XCTAssertEqual(Money.parse("1,234,567.89"), 1234567.89)
    }

    func testPartialInput() {
        XCTAssertEqual(Money.parse("45"), 45)
        XCTAssertEqual(Money.parse("45."), 45)
        XCTAssertEqual(Money.parse(".50"), 0.5)
        XCTAssertEqual(Money.parse(",5"), 0.5)
        XCTAssertEqual(Money.parse("0"), 0)
    }

    func testRejectsNonNumbers() {
        XCTAssertNil(Money.parse(""))
        XCTAssertNil(Money.parse("abc"))
    }

    func testFormattingIsRandWithDotDecimals() {
        XCTAssertEqual(Money.string(1234.56), "R1,234.56")
        XCTAssertEqual(Money.string(45.5), "R45.50")
        XCTAssertEqual(Money.rounded(1234.56), "R1,235")
    }
}
