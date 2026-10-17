import SwiftUI

nonisolated struct SpendSlice: Identifiable, Equatable {
    let category: ExpenseCategory?
    let amount: Double
    let mergedCount: Int

    init(category: ExpenseCategory?, amount: Double, mergedCount: Int = 0) {
        self.category = category
        self.amount = amount
        self.mergedCount = mergedCount
    }

    var id: String { category?.rawValue ?? "merged" }

    var label: String {
        category?.label ?? "+\(mergedCount) more"
    }

    var tint: Color {
        category?.tint ?? .secondary
    }

    var isMerged: Bool { category == nil }

    func share(of total: Double) -> Double {
        total > 0 ? amount / total : 0
    }
}

nonisolated enum SpendBreakdown {
    static func totals(for expenses: [Expense]) -> [ExpenseCategory: Double] {
        expenses.reduce(into: [:]) { running, expense in
            running[expense.category, default: 0] += expense.amount
        }
    }

    static func slices(
        from totals: [ExpenseCategory: Double],
        limit: Int = 6
    ) -> [SpendSlice] {
        let ranked = totals
            .filter { $0.value > 0 }
            .sorted {
                $0.value == $1.value ? $0.key.label < $1.key.label : $0.value > $1.value
            }
            .map { SpendSlice(category: $0.key, amount: $0.value) }

        guard limit > 0 else { return [] }
        guard ranked.count > limit else { return ranked }

        let kept = ranked.prefix(limit - 1)
        let merged = ranked.dropFirst(limit - 1)

        return kept + [
            SpendSlice(
                category: nil,
                amount: merged.reduce(0) { $0 + $1.amount },
                mergedCount: merged.count
            )
        ]
    }

    static func sweep(_ slices: [SpendSlice], progress: Double) -> (drawn: [Double], remainder: Double) {
        let clamped = min(max(progress, 0), 1)
        let total = slices.reduce(0) { $0 + $1.amount }
        let drawn = slices.map { $0.amount * clamped }
        return (drawn, total - drawn.reduce(0, +))
    }
}
