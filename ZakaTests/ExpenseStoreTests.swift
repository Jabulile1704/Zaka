import XCTest
import SwiftData
@testable import Zaka

final class ExpenseStoreTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Expense.self, LoyaltyCard.self,
            configurations: configuration
        )
        context = ModelContext(container)
    }

    override func tearDown() {
        context = nil
        container = nil
    }

    func testExpenseRoundTripsThroughTheStore() throws {
        context.insert(Expense(amount: 249.90, category: .transport, note: "Uber home"))
        let saved = try context.fetch(FetchDescriptor<Expense>())

        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved[0].amount, 249.90)
        XCTAssertEqual(saved[0].category, .transport)
        XCTAssertEqual(saved[0].note, "Uber home")
    }

    func testCategoryIsReadThroughTheRetiredMapping() throws {
        let expense = Expense(amount: 10, category: .takeaways)
        expense.categoryRaw = "food"
        context.insert(expense)

        let saved = try XCTUnwrap(try context.fetch(FetchDescriptor<Expense>()).first)
        XCTAssertEqual(saved.category, .takeaways)
        XCTAssertEqual(saved.categoryRaw, "food", "reading must not rewrite the store")
    }

    func testTitleFallsBackToCategoryWhenThereIsNoNote() {
        XCTAssertEqual(Expense(amount: 1, category: .rent).title, "Rent")
        XCTAssertEqual(Expense(amount: 1, category: .rent, note: "   ").title, "Rent")
        XCTAssertEqual(Expense(amount: 1, category: .rent, note: "October").title, "October")
    }

    @MainActor
    func testDayGroupingAndTotals() {
        let calendar = Calendar.current
        let today = Date.now
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let groups = DayGroup.group([
            Expense(amount: 100, category: .takeaways, date: today),
            Expense(amount: 50, category: .transport, date: today),
            Expense(amount: 25, category: .airtime, date: yesterday)
        ])

        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].title, "Today")
        XCTAssertEqual(groups[0].total, 150)
        XCTAssertEqual(groups[1].title, "Yesterday")
        XCTAssertEqual(groups[1].total, 25)
    }

    @MainActor
    func testDayGroupsAreNewestFirst() {
        let calendar = Calendar.current
        let older = calendar.date(byAdding: .day, value: -5, to: .now)!
        let groups = DayGroup.group([
            Expense(amount: 1, category: .others, date: older),
            Expense(amount: 2, category: .others, date: .now)
        ])
        XCTAssertGreaterThan(groups[0].day, groups[1].day)
    }
}
