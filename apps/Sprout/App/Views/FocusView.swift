import SwiftUI
import SproutKit

struct FocusView: View {
    @Environment(AppModel.self) private var model
    @State private var showCancelConfirm = false

    var body: some View {
        @Bindable var bindable = model

        VStack(spacing: 24) {
            if let sprout = model.activeSprout {
                Text(sprout.nickname)
                    .font(.title2.weight(.semibold))
                Text(sprout.species.name + " · " + sprout.stage.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                SproutSpriteView(sprout: sprout, size: 200)
                    .padding(.top, 4)
            }

            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.4), value: progress)

                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    Text(model.isFocusing ? "Focusing" : "Ready")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 220, height: 220)

            if !model.isFocusing {
                Stepper(value: $bindable.plannedMinutes, in: 5...120, step: 5) {
                    Text("\(model.plannedMinutes) min session")
                }
                .padding(.horizontal, 40)
            }

            if model.isFocusing {
                Button(role: .destructive) {
                    showCancelConfirm = true
                } label: {
                    Text("Give up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal, 40)
                .confirmationDialog(
                    "End this session early?",
                    isPresented: $showCancelConfirm,
                    titleVisibility: .visible
                ) {
                    Button("End session", role: .destructive) { model.cancelFocus() }
                    Button("Keep going", role: .cancel) {}
                } message: {
                    Text("You'll earn no minutes, but your Sprout won't droop.")
                }
            } else {
                Button(action: model.startFocus) {
                    Text("Start")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 40)
            }

            Spacer()
        }
        .padding(.top, 24)
    }

    private var progress: Double {
        guard model.isFocusing, let s = model.currentSession, s.plannedSeconds > 0 else {
            return 0
        }
        return min(1, Double(s.elapsedSeconds) / Double(s.plannedSeconds))
    }

    private var timeString: String {
        let total: Int
        if model.isFocusing, let s = model.currentSession {
            total = max(0, s.plannedSeconds - s.elapsedSeconds)
        } else {
            total = model.plannedMinutes * 60
        }
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
