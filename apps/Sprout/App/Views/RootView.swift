import SwiftUI
import SproutKit

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if model.garden.sprouts.isEmpty {
            HatchView()
        } else {
            TabView {
                FocusView()
                    .tabItem { Label("Focus", systemImage: "leaf.fill") }

                GardenView()
                    .tabItem { Label("Garden", systemImage: "tree.fill") }

                StatsView()
                    .tabItem { Label("Stats", systemImage: "chart.bar.fill") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
        }
    }
}
