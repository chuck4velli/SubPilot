import SwiftUI
import SwiftData

@main
struct SubPilotApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        // Local-only persistence
        .modelContainer(for: [Subscription.self])
    }
}
