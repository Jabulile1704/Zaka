import SwiftUI

/// The fixed set of buckets an expense can fall into.
///
/// Stored on `Expense` as a raw string so the on-disk format survives
/// reordering the cases here.
// `nonisolated` so the SwiftData model, which is itself nonisolated, can read
// these under the target's MainActor-by-default isolation.
nonisolated enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case food
    case groceries
    case transport
    case bills
    case shopping
    case health
    case fun
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .food: "Food"
        case .groceries: "Groceries"
        case .transport: "Transport"
        case .bills: "Bills"
        case .shopping: "Shopping"
        case .health: "Health"
        case .fun: "Fun"
        case .other: "Other"
        }
    }

    var symbol: String {
        switch self {
        case .food: "fork.knife"
        case .groceries: "basket.fill"
        case .transport: "car.fill"
        case .bills: "bolt.fill"
        case .shopping: "bag.fill"
        case .health: "cross.case.fill"
        case .fun: "music.note"
        case .other: "square.grid.2x2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .food: .orange
        case .groceries: .green
        case .transport: .blue
        case .bills: .yellow
        case .shopping: .pink
        case .health: .red
        case .fun: .purple
        case .other: .gray
        }
    }
}
