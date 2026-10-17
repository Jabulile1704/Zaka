import XCTest
@testable import Zaka

final class SpendBreakdownTests: XCTestCase {
    func testTotalsSumPerCategory() {
        let totals = SpendBreakdown.totals(for: [
            Expense(amount: 100, category: .takeaways),
            Expense(amount: 50, category: .takeaways),
            Expense(amount: 25, category: .transport)
        ])
        XCTAssertEqual(totals[.takeaways], 150)
        XCTAssertEqual(totals[.transport], 25)
        XCTAssertNil(totals[.rent])
    }

    func testFewerCategoriesThanTheLimitAreAllKept() {
        let slices = SpendBreakdown.slices(from: [.rent: 3700, .transport: 790], limit: 6)
        XCTAssertEqual(slices.count, 2)
        XCTAssertFalse(slices.contains { $0.isMerged })
        XCTAssertEqual(slices.map(\.category), [.rent, .transport])
    }

    func testExactlyTheLimitIsNotMerged() {
        let totals: [ExpenseCategory: Double] = [
            .rent: 6, .transport: 5, .takeaways: 4, .groceries: 3, .wifi: 2, .airtime: 1
        ]
        let slices = SpendBreakdown.slices(from: totals, limit: 6)
        XCTAssertEqual(slices.count, 6)
        XCTAssertFalse(slices.contains { $0.isMerged })
    }

    func testOverTheLimitMergesTheSmallest() {
        let totals: [ExpenseCategory: Double] = [
            .rent: 7, .transport: 6, .takeaways: 5,
            .groceries: 4, .wifi: 3, .airtime: 2, .haircut: 1
        ]
        let slices = SpendBreakdown.slices(from: totals, limit: 6)

        XCTAssertEqual(slices.count, 6, "never more slices than the limit")
        XCTAssertEqual(slices.map(\.category).prefix(5), [.rent, .transport, .takeaways, .groceries, .wifi])

        let last = slices[5]
        XCTAssertTrue(last.isMerged)
        XCTAssertEqual(last.amount, 3, "airtime and haircut combined")
        XCTAssertEqual(last.mergedCount, 2)
        XCTAssertEqual(last.label, "+2 more")
    }

    func testMergingPreservesTheTotal() {
        let totals: [ExpenseCategory: Double] = [
            .rent: 7, .transport: 6, .takeaways: 5, .groceries: 4,
            .wifi: 3, .airtime: 2, .haircut: 1, .dates: 10
        ]
        let expected = totals.values.reduce(0, +)
        let sliced = SpendBreakdown.slices(from: totals, limit: 4).reduce(0) { $0 + $1.amount }
        XCTAssertEqual(sliced, expected, accuracy: 0.0001)
    }

    func testZeroAndNegativeAmountsAreDropped() {
        let slices = SpendBreakdown.slices(from: [.rent: 100, .wifi: 0, .airtime: -5])
        XCTAssertEqual(slices.map(\.category), [.rent])
    }

    func testTiesAreOrderedPredictably() {
        let first = SpendBreakdown.slices(from: [.wifi: 50, .airtime: 50, .rent: 50])
        let again = SpendBreakdown.slices(from: [.rent: 50, .wifi: 50, .airtime: 50])
        XCTAssertEqual(first.map(\.id), again.map(\.id), "equal amounts must not reorder run to run")
        XCTAssertEqual(first.map(\.category), [.airtime, .rent, .wifi])
    }

    func testEmptyAndDegenerateInput() {
        XCTAssertTrue(SpendBreakdown.slices(from: [:]).isEmpty)
        XCTAssertTrue(SpendBreakdown.slices(from: [.rent: 100], limit: 0).isEmpty)
        XCTAssertEqual(SpendBreakdown.slices(from: [.rent: 100], limit: 1).count, 1)
    }

    func testShareOfTotal() {
        let slice = SpendSlice(category: .rent, amount: 25)
        XCTAssertEqual(slice.share(of: 100), 0.25)
        XCTAssertEqual(slice.share(of: 0), 0, "no division by zero on an empty month")
    }
}
