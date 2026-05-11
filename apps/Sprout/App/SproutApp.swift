import SwiftUI
import SproutKit

@main
struct SproutApp: App {
    @State private var model = AppModel(
        store: FileGardenStore(url: FileGardenStore.defaultURL())
    )
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .onChange(of: scenePhase) { _, new in
                    model.handleScenePhase(new)
                }
        }
    }
}
