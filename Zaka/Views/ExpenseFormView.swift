import SwiftUI
import SwiftData

struct ExpenseFormView: View {
    private enum Field { case amount, note }

    let editing: Expense?
    var isActive: Bool = true
    let onFinish: () -> Void

    @Environment(\.modelContext) private var context

    @State private var amountText = ""
    @State private var category: ExpenseCategory = .takeaways
    @State private var date: Date = .now
    @State private var note = ""
    @State private var saveCount = 0
    @FocusState private var focus: Field?
    @Namespace private var glass

    private var isEditing: Bool { editing != nil }

    private var amount: Double? {
        guard let value = Money.parse(amountText), value > 0 else { return nil }
        return value
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    amountCard
                    categorySection
                    detailsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 48)
            }
            .scrollDismissesKeyboard(.interactively)
            .background { AmbientBackground() }
            .navigationTitle(isEditing ? "Edit Expense" : "Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isEditing {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { onFinish() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(amount == nil)
                        .buttonStyle(.glassProminent)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focus = nil }
                }
            }
        }
        .onAppear {
            loadIfEditing()
            focusAmount()
        }
        .onChange(of: isActive) { _, active in
            if active { focusAmount() } else { focus = nil }
        }
        .sensoryFeedback(.selection, trigger: category)
        .sensoryFeedback(.success, trigger: saveCount)
    }

    private var amountCard: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(Money.symbol)
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            TextField("0.00", text: $amountText)
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .keyboardType(.decimalPad)
                .focused($focus, equals: .amount)
                .monospacedDigit()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
        .contentShape(.rect)
        .onTapGesture { focus = .amount }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 8)

            GlassEffectContainer(spacing: 14) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                    spacing: 10
                ) {
                    ForEach(ExpenseCategory.allCases) { option in
                        chip(for: option)
                    }
                }
            }
        }
    }

    private func chip(for option: ExpenseCategory) -> some View {
        let isSelected = option == category

        return Button {
            withAnimation(.snappy(duration: 0.3, extraBounce: 0.12)) {
                category = option
            }
            focus = nil
        } label: {
            VStack(spacing: 6) {
                Image(systemName: option.symbol)
                    .font(.system(size: 18))
                    .frame(height: 21)
                Text(option.label)
                    .font(.caption2.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        }
        .buttonStyle(.plain)
        .glassEffect(
            .regular.tint(isSelected ? option.tint : nil).interactive(),
            in: .rect(cornerRadius: 20)
        )
        .glassEffectID(option, in: glass)
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .padding(.horizontal, 20)
                .padding(.vertical, 11)

            Divider().padding(.leading, 20)

            TextField("Note", text: $note)
                .focused($focus, equals: .note)
                .submitLabel(.done)
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 26))
    }

    private func focusAmount() {
        guard editing == nil, isActive, amountText.isEmpty else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard isActive else { return }
            focus = .amount
        }
    }

    private func loadIfEditing() {
        guard let expense = editing else { return }
        guard amountText.isEmpty else { return }
        amountText = String(format: "%.2f", expense.amount)
        category = expense.category
        date = expense.date
        note = expense.note
    }

    private func save() {
        guard let amount else { return }

        if let expense = editing {
            expense.amount = amount
            expense.category = category
            expense.date = date
            expense.note = note
        } else {
            context.insert(
                Expense(amount: amount, category: category, date: date, note: note)
            )
            reset()
        }
        saveCount += 1
        onFinish()
    }

    private func reset() {
        amountText = ""
        category = .takeaways
        date = .now
        note = ""
        focus = nil
    }
}
