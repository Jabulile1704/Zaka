import SwiftUI
import SwiftData

struct CardListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \LoyaltyCard.addedAt, order: .forward) private var cards: [LoyaltyCard]

    @State private var adding = false
    @State private var showing: LoyaltyCard?
    @State private var deleteCount = 0

    var body: some View {
        NavigationStack {
            Group {
                if cards.isEmpty {
                    ContentUnavailableView {
                        Label("No cards yet", systemImage: "creditcard")
                    } description: {
                        Text("Keep your shop cards here so you can leave the plastic at home.")
                    } actions: {
                        Button("Add a card") { adding = true }
                            .buttonStyle(.glassProminent)
                    }
                } else {
                    list
                }
            }
            .background { AmbientBackground() }
            .navigationTitle("Cards")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        adding = true
                    } label: {
                        Label("Add card", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $adding) {
            CardFormView(editing: nil) { adding = false }
        }
        .sheet(item: $showing) { card in
            CardDetailView(card: card)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: deleteCount)
    }

    private var list: some View {
        List {
            ForEach(cards) { card in
                Button {
                    showing = card
                } label: {
                    CardRow(card: card)
                }
                .buttonStyle(.plain)
                .listRowBackground(Rectangle().fill(.regularMaterial))
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        context.delete(card)
                        deleteCount += 1
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .animation(.snappy, value: cards.count)
    }
}

private struct CardRow: View {
    let card: LoyaltyCard

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(card.tint.gradient)
                .frame(width: 46, height: 30)
                .overlay {
                    Image(systemName: "barcode")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.9))
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(card.name)
                    .font(.body)
                    .lineLimit(1)
                Text(card.lastFour.isEmpty ? card.symbology.label : "•••• \(card.lastFour)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
    }
}
