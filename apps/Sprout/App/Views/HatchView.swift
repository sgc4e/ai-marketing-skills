import SwiftUI
import SproutKit

struct HatchView: View {
    @Environment(AppModel.self) private var model
    @State private var nickname: String = ""
    @State private var wobble = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("🥚")
                .font(.system(size: 120))
                .rotationEffect(.degrees(wobble ? -8 : 8))
                .animation(
                    .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                    value: wobble
                )
                .onAppear { wobble = true }

            VStack(spacing: 6) {
                Text("Something's waking up.")
                    .font(.title2.weight(.semibold))
                Text("Give your first Sprout a name to hatch it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            TextField("Nickname", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 48)
                .submitLabel(.go)
                .onSubmit(hatch)

            Button(action: hatch) {
                Text("Hatch")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 48)
            .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)

            Spacer()
        }
    }

    private func hatch() {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        model.hatchSprout(nickname: trimmed)
    }
}
