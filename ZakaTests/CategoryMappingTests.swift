import XCTest
@testable import Zaka

final class CategoryMappingTests: XCTestCase {
    func testLiveValuesMapToThemselves() {
        XCTAssertEqual(ExpenseCategory.stored("takeaways"), .takeaways)
        XCTAssertEqual(ExpenseCategory.stored("groceries"), .groceries)
        XCTAssertEqual(ExpenseCategory.stored("transport"), .transport)
        XCTAssertEqual(ExpenseCategory.stored("utilities"), .utilities)
        XCTAssertEqual(ExpenseCategory.stored("other"), .others)
    }

    func testRetiredValuesMapToTheirReplacement() {
        XCTAssertEqual(ExpenseCategory.stored("food"), .takeaways)
        XCTAssertEqual(ExpenseCategory.stored("bills"), .accounts)
        XCTAssertEqual(ExpenseCategory.stored("fun"), .others)
    }

    func testUnknownValueFallsBackRatherThanCrashing() {
        XCTAssertEqual(ExpenseCategory.stored("nonsense"), .others)
        XCTAssertEqual(ExpenseCategory.stored(""), .others)
    }

    func testEveryCategoryHasLabelSymbolAndDistinctRawValue() {
        let raws = Set(ExpenseCategory.allCases.map(\.rawValue))
        XCTAssertEqual(raws.count, ExpenseCategory.allCases.count)
        for category in ExpenseCategory.allCases {
            XCTAssertFalse(category.label.isEmpty)
            XCTAssertFalse(category.symbol.isEmpty)
        }
    }
}
