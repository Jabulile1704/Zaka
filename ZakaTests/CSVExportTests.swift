import XCTest
@testable import Zaka

final class CSVExportTests: XCTestCase {
    func testRowsAreOldestFirstAndUseCategoryLabels() {
        let calendar = Calendar.current
        let newer = Date.now
        let older = calendar.date(byAdding: .day, value: -2, to: newer)!

        let rows = CSVExport.rows(from: [
            Expense(amount: 10, category: .transport, date: newer, note: "Bolt"),
            Expense(amount: 20, category: .takeaways, date: older, note: "KFC")
        ])

        XCTAssertEqual(rows.map(\.note), ["KFC", "Bolt"])
        XCTAssertEqual(rows.map(\.category), ["Takeaways", "Transport"])
    }

    func testHeaderAndAmountFormat() {
        let text = CSVExport.text(for: [
            ExpenseCSVRow(date: .now, category: "Rent", note: "", amount: 3700)
        ])
        let lines = text.split(separator: "\n")

        XCTAssertEqual(lines.first, "Date,Category,Note,Amount")
        XCTAssertTrue(text.hasSuffix("\n"))
        XCTAssertTrue(text.contains(",3700.00"), "amounts are plain numbers so spreadsheets parse them")
        XCTAssertFalse(text.contains("R3"), "no currency symbol in the export")
        XCTAssertFalse(text.contains("3,700"), "no grouping separator in the export")
    }

    func testAwkwardNotesSurvive() {
        let text = CSVExport.text(for: [
            ExpenseCSVRow(date: .now, category: "Groceries", note: "Checkers, Sandton", amount: 1),
            ExpenseCSVRow(date: .now, category: "Transport", note: "Said \"urgent\"", amount: 2),
            ExpenseCSVRow(date: .now, category: "Others", note: "", amount: 3)
        ])

        XCTAssertTrue(text.contains("\"Checkers, Sandton\""))
        XCTAssertTrue(text.contains("\"Said \"\"urgent\"\"\""))
        XCTAssertTrue(text.contains(",\"\","))
    }

    func testFilenameIsStamped() {
        let stamp = DateFormatter()
        stamp.locale = Locale(identifier: "en_US_POSIX")
        stamp.dateFormat = "yyyy-MM-dd"
        let date = stamp.date(from: "2026-10-16")!
        XCTAssertEqual(CSVExport.filename(on: date), "Zaka-expenses-2026-10-16.csv")
    }
}
