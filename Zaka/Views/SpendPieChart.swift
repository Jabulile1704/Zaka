import SwiftUI
import Charts

struct SpendPieChart: View {
    let slices: [SpendSlice]
    let total: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reveal: Double = 0

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RevealingDonut(progress: reveal, slices: slices)
                    .frame(height: 210)

                VStack(spacing: 2) {
                    Text(Money.rounded(total))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: total))
                    Text("this month")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .opacity(reveal)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Spending by category")
            .accessibilityValue(spokenSummary)

            VStack(spacing: 10) {
                ForEach(Array(slices.enumerated()), id: \.element.id) { index, slice in
                    LegendRow(slice: slice, total: total)
                        .opacity(legendOpacity(at: index))
                        .offset(y: (1 - legendOpacity(at: index)) * 8)
                }
            }
        }
        .padding(.vertical, 8)
        .task(id: slices.map(\.id)) { await runReveal() }
    }

    private func runReveal() async {
        reveal = 0
        // One frame has to render at zero, or there is no value to animate
        // from and the donut snaps straight to full.
        try? await Task.sleep(for: .milliseconds(32))
        if reduceMotion {
            withAnimation(.easeOut(duration: 0.25)) { reveal = 1 }
        } else {
            withAnimation(.easeOut(duration: 0.85)) { reveal = 1 }
        }
    }

    /// Rows fade in behind the sweep, each a little after the last.
    private func legendOpacity(at index: Int) -> Double {
        guard !reduceMotion else { return reveal }
        let start = 0.35 + Double(index) * 0.07
        return min(max((reveal - start) / 0.25, 0), 1)
    }

    private var spokenSummary: String {
        slices
            .map { "\($0.label), \(Money.rounded($0.amount))" }
            .joined(separator: ". ")
    }
}

private struct DonutRow: Identifiable {
    let id: String
    let amount: Double
    let colour: Color
}

/// Animatable so `body` is re-evaluated at every step of the sweep. Reading a
/// plain state value would hand back the final progress for the whole
/// animation and the donut would snap into place in one frame.
private struct RevealingDonut: View, Animatable {
    var progress: Double
    let slices: [SpendSlice]

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Chart(rows) { row in
            SectorMark(
                angle: .value("Amount", row.amount),
                innerRadius: .ratio(0.58),
                angularInset: 1.5
            )
            .foregroundStyle(row.colour)
            .cornerRadius(4)
        }
        .chartLegend(.hidden)
        .rotationEffect(.degrees(-115 * (1 - progress)))
        .scaleEffect(0.86 + 0.14 * progress)
    }

    private var rows: [DonutRow] {
        let (drawn, remainder) = SpendBreakdown.sweep(slices, progress: progress)

        var rows = zip(slices, drawn).map {
            DonutRow(id: $0.id, amount: $1, colour: $0.tint)
        }
        if remainder > 0 {
            rows.append(DonutRow(id: "sweep", amount: remainder, colour: .clear))
        }
        return rows
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
