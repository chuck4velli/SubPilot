import SwiftData

enum PreviewSwiftData {
    /// Fresh, in-memory container with your models registered.
    static func container(seed: Bool = false) -> ModelContainer {
        let schema = Schema([Subscription.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let container = try! ModelContainer(for: schema, configurations: config)
        
        if seed {
            let context = container.mainContext
            makeSampleSubscriptions().forEach { context.insert($0) }
            try? context.save()
        }
        return container
    }
}
