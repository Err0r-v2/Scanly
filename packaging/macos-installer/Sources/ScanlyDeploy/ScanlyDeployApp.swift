import SwiftUI

@main
struct ScanlyDeployApp: App {
    @StateObject private var model = InstallerModel()

    var body: some Scene {
        Window("Scanly Deploy", id: "main") {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 880, minHeight: 620)
                .background(Theme.paper)
                .preferredColorScheme(.light)
        }
        .windowResizability(.contentMinSize)
        .windowStyle(.hiddenTitleBar)
    }
}
