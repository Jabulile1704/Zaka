import Foundation
import SwiftUI
import UniformTypeIdentifiers

nonisolated struct ExpenseCSVRow {
    let date: Date
    let category: String
    let note: String
    let amount: Double
}

nonisolated enum CSVExport {
    static let header = "Date,Category,Note,Amount"

    static func rows(from expenses: [Expense]) -> [ExpenseCSVRow] {
        expenses
            .sorted { $0.date < $1.date }
            .map {
                ExpenseCSVRow(
                    date: $0.date,
                    category: $0.category.label,
                    note: $0.note,
                    amount: $0.amount
                )
            }
    }

    static func text(for rows: [ExpenseCSVRow]) -> String {
        let stamp = formatter(format: "yyyy-MM-dd HH:mm")

        var lines = [header]
        lines.reserveCapacity(rows.count + 1)

        for row in rows {
            lines.append([
                quoted(stamp.string(from: row.date)),
                quoted(row.category),
                quoted(row.note),
                String(format: "%.2f", row.amount)
            ].joined(separator: ","))
        }

        return lines.joined(separator: "\n") + "\n"
    }

    static func filename(on date: Date = .now) -> String {
        "Zaka-expenses-\(formatter(format: "yyyy-MM-dd").string(from: date)).csv"
    }

    private static func formatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter
    }

    private static func quoted(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}

nonisolated struct ExpensesCSV: Transferable {
    let text: String
    let filename: String

    init(expenses: [Expense]) {
        self.text = CSVExport.text(for: CSVExport.rows(from: expenses))
        self.filename = CSVExport.filename()
    }

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { csv in
            Data(csv.text.utf8)
        }
        .suggestedFileName { $0.filename }
    }
}
