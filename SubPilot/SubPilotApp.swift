import SwiftUI
import SwiftData

@main
struct SubPilotApp: App {
    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
        // Local-only persistence
        .modelContainer(for: [Subscription.self])
    }
}
