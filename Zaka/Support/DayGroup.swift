import Foundation

struct DayGroup: Identifiable {
    let day: Date
    let expenses: [Expense]

    var id: Date { day }
    var total: Double { expenses.reduce(0) { $0 + $1.amount } }

    var title: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }

        let sameYear = calendar.component(.year, from: day)
            == calendar.component(.year, from: .now)
        return day.formatted(
            sameYear
                ? .dateTime.weekday(.abbreviated).day().month(.abbreviated)
                : .dateTime.day().month(.abbreviated).year()
        )
    }

    static func group(_ expenses: [Expense]) -> [DayGroup] {
        let calendar = Calendar.current
        let buckets = Dictionary(grouping: expenses) {
            calendar.startOfDay(for: $0.date)
        }
        return buckets
            .map { day, items in
                DayGroup(day: day, expenses: items.sorted { $0.date > $1.date })
            }
            .sorted { $0.day > $1.day }
    }
}
