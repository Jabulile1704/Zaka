import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double
    var categoryRaw: String
    var date: Date
    var note: String

    init(amount: Double, category: ExpenseCategory, date: Date = .now, note: String = "") {
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.date = date
        self.note = note
    }

    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var hasNote: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var title: String {
        hasNote ? note : category.label
    }
}
