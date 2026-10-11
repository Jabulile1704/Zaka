import SwiftUI
import SwiftData

struct RootView: View {
    enum Screen: Hashable { case expenses, add, insights }

    @State private var selection: Screen = .expenses

    var body: some View {
        TabView(selection: $selection) {
            Tab("Expenses", systemImage: "list.bullet", value: Screen.expenses) {
                ExpenseListView()
            }

            Tab("Add", systemImage: "plus", value: Screen.add) {
                // `isActive` lets the form know when it is the visible tab, which
                // is the only reliable moment to claim keyboard focus.
                ExpenseFormView(editing: nil, isActive: selection == .add) {
                    selection = .expenses
                }
            }

            Tab("Insights", systemImage: "chart.bar.fill", value: Screen.insights) {
                InsightsView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            MonthTotalAccessory { selection = .insights }
        }
    }
}

/// The running month-to-date total, parked in the glass strip above the tab bar.
private struct MonthTotalAccessory: View {
    @Query private var expenses: [Expense]
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    let onTap: () -> Void

    private var total: Double {
        let calendar = Calendar.current
        guard let month = calendar.dateInterval(of: .month, for: .now) else { return 0 }
        return expenses.filter { month.contains($0.date) }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Collapsed into the tab bar there is only room for the figure.
                if placement != .inline {
                    Text("This month")
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Text(Money.rounded(total))
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: total))
            }
            .font(.subheadline)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: total)
    }
}
