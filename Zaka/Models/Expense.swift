import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double = 0
    var categoryRaw: String = ExpenseCategory.others.rawValue
    var date: Date = Date.now
    var note: String = ""

    init(amount: Double, category: ExpenseCategory, date: Date = .now, note: String = "") {
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.date = date
        self.note = note
    }

    var category: ExpenseCategory {
        get { ExpenseCategory.stored(categoryRaw) }
        set { categoryRaw = newValue.rawValue }
    }

    var hasNote: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var title: String {
        hasNote ? note : category.label
    }
}
