import SwiftUI
import SproutKit

/// Shown briefly when a focus session completes successfully.
/// Lightweight celebration — no third-party assets, no haptics here
/// (those fire from AppModel.applyFinished so they happen even if the view isn't visible).
struct CompletionCelebration: View {
    let sprout: Sprout
    let earnedMinutes: Int
    var onDismiss: () -> Void

    @State private var animateIn = false

    var body: some View {
        VStack(spacing: 24) {
            Text(sprout.species.emoji)
                .font(.system(size: 96))
                .scaleEffect(animateIn ? 1.0 : 0.6)
                .rotationEffect(.degrees(animateIn ? 0 : -8))
                .animation(.spring(response: 0.5, dampingFraction: 0.55), value: animateIn)

            VStack(spacing: 8) {
                Text("Nice work.")
                    .font(.title2.weight(.semibold))
                Text("\(sprout.nickname) earned \(earnedMinutes) min.")
                    .foregroundStyle(.secondary)
            }
            .opacity(animateIn ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.2), value: animateIn)

            Button("Keep going", action: onDismiss)
                .buttonStyle(.borderedProminent)
                .opacity(animateIn ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.35), value: animateIn)
        }
        .padding(32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding()
        .onAppear { animateIn = true }
    }
}
