import SwiftUI
import Charts

struct SpendPieChart: View {
    let slices: [SpendSlice]
    let total: Double

    var body: some View {
        VStack(spacing: 18) {
            Chart(slices) { slice in
                SectorMark(
                    angle: .value("Amount", slice.amount),
                    innerRadius: .ratio(0.58),
                    angularInset: 1.5
                )
                .foregroundStyle(slice.tint)
                .cornerRadius(4)
            }
            .chartLegend(.hidden)
            .frame(height: 210)
            .overlay {
                VStack(spacing: 2) {
                    Text(Money.rounded(total))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: total))
                    Text("this month")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel("Spending by category")
            .accessibilityValue(spokenSummary)

            VStack(spacing: 10) {
                ForEach(slices) { slice in
                    LegendRow(slice: slice, total: total)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var spokenSummary: String {
        slices
            .map { "\($0.label), \(Money.rounded($0.amount))" }
            .joined(separator: ". ")
    }
}

private struct LegendRow: View {
    let slice: SpendSlice
    let total: Double

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(slice.tint)
                .frame(width: 10, height: 10)

            Text(slice.label)
                .foregroundStyle(slice.isMerged ? .secondary : .primary)

            Spacer(minLength: 8)

            Text(Money.rounded(slice.amount))
                .monospacedDigit()
                .contentTransition(.numericText(value: slice.amount))

            Text("\(Int((slice.share(of: total) * 100).rounded()))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 38, alignment: .trailing)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(slice.label), \(Money.rounded(slice.amount))")
    }
}
