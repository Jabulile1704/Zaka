import SwiftUI

/// The opening animation: the coin spins to rest while notes fan out beneath
/// it and two loose coins drift up.
///
/// iOS launch screens are static by definition — the system draws them before
/// any of our code runs — so this is an ordinary view shown over the app. The
/// real launch screen is set to the same background colour, so the hand-off
/// from one to the other is invisible.
///
/// The store is local and opens instantly, so this is a deliberate pause
/// rather than cover for real work. `duration` is the whole of it, and a tap
/// skips straight through.
struct SplashView: View {
    var duration: Duration = .milliseconds(1950)
    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme

    @State private var spin: Double = 0
    @State private var fanned = false
    @State private var lifted = false
    @State private var textShown = false
    @State private var finished = false

    private var palette: CoinPalette { .of(scheme) }
    private var noteColours: [Color] { NotePalette.colours(scheme) }

    var body: some View {
        ZStack {
            AmbientBackground()
            moneyFan
            centrepiece
        }
        .contentShape(.rect)
        .onTapGesture(perform: finish)
        .task(run)
    }

    // MARK: - Pieces

    private var centrepiece: some View {
        VStack(spacing: 24) {
            SpinningCoin(angle: spin, size: 132, palette: palette)
                .shadow(color: .black.opacity(0.22), radius: 22, y: 12)

            VStack(spacing: 10) {
                Text("Zaka")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                Text("Man make the nyuku, nyuku don’t make the man")
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 258)
            }
            .opacity(textShown ? 1 : 0)
            .offset(y: textShown ? 0 : 12)
        }
        .padding(.bottom, 188)
    }

    /// The notes fan out from behind the coin and settle; the small coins rise
    /// past them, turning slowly.
    private var moneyFan: some View {
        ZStack(alignment: .bottom) {
            Color.clear

            note(index: 0, angle: -17, x: -118, y: -54)
            note(index: 1, angle: -3, x: -12, y: -76)
            note(index: 2, angle: 14, x: 94, y: -44)

            SpinningCoin(angle: spin * 0.55, size: 54, palette: palette)
                .offset(x: -108, y: lifted ? -14 : 54)
                .opacity(lifted ? 1 : 0)

            SpinningCoin(angle: -spin * 0.75, size: 40, palette: palette)
                .offset(x: 120, y: lifted ? -140 : -40)
                .opacity(lifted ? 1 : 0)
        }
        .padding(.bottom, -26)
    }

    private func note(index: Int, angle: Double, x: CGFloat, y: CGFloat) -> some View {
        NoteCard(width: 132, colour: noteColours[index])
            .rotationEffect(.degrees(fanned ? angle : 0))
            .offset(x: fanned ? x : 0, y: fanned ? y : 28)
            .opacity(fanned ? 1 : 0)
            .scaleEffect(fanned ? 1 : 0.84)
    }

    // MARK: - Timing

    @Sendable private func run() async {
        if reduceMotion {
            withAnimation(.easeOut(duration: 0.45)) {
                fanned = true
                lifted = true
                textShown = true
            }
            try? await Task.sleep(for: .milliseconds(1000))
        } else {
            // Three turns, easing to a stop face-on: 1080 is a whole number of
            // revolutions, so it lands showing the R.
            withAnimation(.easeOut(duration: 1.7)) { spin = 1080 }
            withAnimation(.spring(response: 0.75, dampingFraction: 0.68).delay(0.15)) {
                fanned = true
            }
            withAnimation(.easeOut(duration: 1.2).delay(0.25)) { lifted = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.55)) { textShown = true }
            try? await Task.sleep(for: duration)
        }
        finish()
    }

    private func finish() {
        guard !finished else { return }
        finished = true
        onFinish()
    }
}
