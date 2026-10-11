import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    /// 0 is the current month, -1 last month, and so on.
    @State private var monthOffset = 0

    var body: some View {
        NavigationStack {
            Group {
                if monthExpenses.isEmpty {
                    ContentUnavailableView(
                        "Nothing this month",
                        systemImage: "chart.bar",
                        description: Text("Expenses you add will be summarised here.")
                    )
                } else {
                    content
                }
            }
            .background { AmbientBackground() }
            .navigationTitle("Insights")
            .safeAreaInset(edge: .top) { monthPicker }
        }
        .sensoryFeedback(.selection, trigger: monthOffset)
    }

    private var content: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Money.rounded(total))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: total))
                    Text("\(monthExpenses.count) expense\(monthExpenses.count == 1 ? "" : "s") · \(Money.rounded(dailyAverage)) a day")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .listRowBackground(Rectangle().fill(.regularMaterial))
            }

            Section("By category") {
                ForEach(breakdown, id: \.category) { row in
                    CategoryBar(row: row, total: total)
                        .listRowBackground(Rectangle().fill(.regularMaterial))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .animation(.snappy(duration: 0.35), value: monthOffset)
    }

    private var monthPicker: some View {
        HStack(spacing: 2) {
            Button {
                monthOffset -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 38)
                    .contentShape(.rect)
            }

            Text(monthStart.formatted(.dateTime.month(.wide).year()))
                .font(.subheadline.weight(.semibold))
                .frame(minWidth: 140)

            Button {
                monthOffset += 1
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 44, height: 38)
                    .contentShape(.rect)
            }
            .disabled(monthOffset >= 0)
        }
        .buttonStyle(.plain)
        .padding(3)
        .glassEffect(.regular.interactive(), in: .capsule)
        .padding(.bottom, 6)
    }

    // MARK: - Figures

    private var monthStart: Date {
        let calendar = Calendar.current
        let thisMonth = calendar.dateInterval(of: .month, for: .now)?.start ?? .now
        return calendar.date(byAdding: .month, value: monthOffset, to: thisMonth) ?? thisMonth
    }

    private var monthExpenses: [Expense] {
        let calendar = Calendar.current
        guard let range = calendar.dateInterval(of: .month, for: monthStart) else {
            return []
        }
        return expenses.filter { range.contains($0.date) }
    }

    private var total: Double {
        monthExpenses.reduce(0) { $0 + $1.amount }
    }

    /// Averaged over days elapsed, so the current month isn't flattened by
    /// days that haven't happened yet.
    private var dailyAverage: Double {
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        let days = calendar.isDate(monthStart, equalTo: .now, toGranularity: .month)
            ? calendar.component(.day, from: .now)
            : daysInMonth
        return total / Double(max(1, days))
    }

    private var breakdown: [CategoryTotal] {
        Dictionary(grouping: monthExpenses, by: \.category)
            .map { CategoryTotal(category: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }
}

struct CategoryTotal {
    let category: ExpenseCategory
    let amount: Double
}

private struct CategoryBar: View {
    let row: CategoryTotal
    let total: Double

    private var fraction: Double {
        total > 0 ? row.amount / total : 0
    }

    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 10) {
                Image(systemName: row.category.symbol)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(row.category.tint.gradient, in: .circle)

                Text(row.category.label)
                Spacer(minLength: 8)
                Text(Money.rounded(row.amount))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: row.amount))
                Text("\(Int((fraction * 100).rounded()))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .frame(width: 38, alignment: .trailing)
            }
            .font(.subheadline)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule()
                        .fill(row.category.tint.gradient)
                        .frame(width: max(3, geometry.size.width * fraction))
                }
            }
            .frame(height: 6)
            .animation(.smooth(duration: 0.45), value: fraction)
        }
        .padding(.vertical, 4)
    }
}
