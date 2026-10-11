import SwiftUI

struct CoinMark: View {
    var size: CGFloat
    var palette: CoinPalette
    var showsLetter: Bool = true

    private var unit: CGFloat { size / 100 }

    var body: some View {
        ZStack {
            Circle()
                .fill(palette.ring)
                .frame(width: 84 * unit, height: 84 * unit)

            Circle()
                .stroke(
                    palette.groove,
                    style: StrokeStyle(
                        lineWidth: 4.5 * unit,
                        dash: [2.4 * unit, 2.4 * unit]
                    )
                )
                .frame(width: 79.5 * unit, height: 79.5 * unit)

            Circle()
                .fill(palette.field)
                .frame(width: 74 * unit, height: 74 * unit)

            Circle()
                .fill(palette.centre)
                .frame(width: 52 * unit, height: 52 * unit)
                .overlay {
                    Circle().stroke(palette.letter.opacity(0.28), lineWidth: 1.5 * unit)
                }

            if showsLetter {
                Text("R")
                    .font(.system(size: 29 * unit, weight: .heavy, design: .rounded))
                    .foregroundStyle(palette.letter)
            }
        }
        .frame(width: size, height: size)
    }
}

struct NoteCard: View {
    var width: CGFloat
    var colour: Color

    private var height: CGFloat { width * 0.515 }

    var body: some View {
        RoundedRectangle(cornerRadius: width * 0.068, style: .continuous)
            .fill(colour)
            .frame(width: width, height: height)
            .overlay {
                RoundedRectangle(cornerRadius: width * 0.04, style: .continuous)
                    .stroke(.white.opacity(0.42), lineWidth: 1.3)
                    .padding(width * 0.053)
            }
            .overlay(alignment: .leading) {
                Circle()
                    .fill(.white.opacity(0.30))
                    .frame(width: width * 0.18, height: width * 0.18)
                    .padding(.leading, width * 0.105)
            }
            .shadow(color: .black.opacity(0.18), radius: 10, y: 6)
    }
}

struct SpinningCoin: View, Animatable {
    var angle: Double
    var size: CGFloat
    var palette: CoinPalette

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    private var facingUs: Bool {
        let turn = (angle.truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360)
        return turn < 90 || turn > 270
    }

    var body: some View {
        CoinMark(size: size, palette: palette, showsLetter: facingUs)
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.45
            )
    }
}
