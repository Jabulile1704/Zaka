import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var editing: Expense?
    @State private var deleteCount = 0

    private var groups: [DayGroup] { DayGroup.group(expenses) }

    var body: some View {
        NavigationStack {
            Group {
                if expenses.isEmpty {
                    ContentUnavailableView {
                        Label("No expenses yet", systemImage: "wallet.bifold")
                    } description: {
                        Text("Tap **Add** to record your first one.")
                    }
                } else {
                    list
                }
            }
            .background { AmbientBackground() }
            .navigationTitle("Expenses")
        }
        .sheet(item: $editing) { expense in
            ExpenseFormView(editing: expense) { editing = nil }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: deleteCount)
    }

    private var list: some View {
        List {
            ForEach(groups) { group in
                Section {
                    ForEach(group.expenses) { expense in
                        Button {
                            editing = expense
                        } label: {
                            ExpenseRow(expense: expense)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Rectangle().fill(.regularMaterial))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                context.delete(expense)
                                deleteCount += 1
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text(group.title)
                        Spacer()
                        Text(Money.string(group.total))
                            .monospacedDigit()
                            .contentTransition(.numericText(value: group.total))
                    }
                    .font(.footnote.weight(.medium))
                    .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .animation(.snappy, value: expenses.count)
    }
}

private struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.symbol)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(expense.category.tint.gradient, in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.body)
                    .lineLimit(1)
                if expense.hasNote {
                    Text(expense.category.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            Text(Money.string(expense.amount))
                .font(.body.weight(.medium))
                .monospacedDigit()
        }
        .padding(.vertical, 2)
        .contentShape(.rect)
    }
}
