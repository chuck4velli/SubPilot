import SwiftUI

public extension View {
    /// Uses native `.emptyState` on iOS 18+, and a lightweight fallback on iOS 17.
    @ViewBuilder
    func emptyStateCompatibility(
        _ isEmpty: Bool,
        title: Text,
        description: Text? = nil,
        systemImage: String? = nil,
        @ViewBuilder actions: () -> some View = { EmptyView() }
    ) -> some View {
        if #available(iOS 18.0, *) {
            self.emptyState(
                isEmpty,
                title: title,
                description: description,
                systemImage: systemImage,
                actions: actions
            )
        } else {
            ZStack {
                self
                if isEmpty {
                    
                }
            }
        }
    }
}
