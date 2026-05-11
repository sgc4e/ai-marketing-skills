import SwiftUI
import SproutKit

struct SettingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationStack {
            Form {
                Section("Defaults") {
                    @Bindable var bindable = model
                    Stepper(value: $bindable.plannedMinutes, in: 5...120, step: 5) {
                        Text("Session length: \(model.plannedMinutes) min")
                    }
                }

                Section("Focus enforcement") {
                    HStack {
                        Image(systemName: "iphone.gen3")
                        VStack(alignment: .leading) {
                            Text("Soft mode")
                                .font(.subheadline.weight(.medium))
                            Text("Your Sprout droops if you leave the app mid-session.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack {
                        Image(systemName: "lock.shield")
                        VStack(alignment: .leading) {
                            Text("Hard mode")
                                .font(.subheadline.weight(.medium))
                            Text("Block selected apps with Screen Time. Coming soon.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("About") {
                    Text("Sprout · v0.1")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
