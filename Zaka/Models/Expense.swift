import Foundation
import SwiftData

@Model
final class Expense {
    /// Always positive — this app only tracks money going out.
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

    /// What to show as the row's headline: the note if there is one, else the category.
    var title: String {
        hasNote ? note : category.label
    }
}
