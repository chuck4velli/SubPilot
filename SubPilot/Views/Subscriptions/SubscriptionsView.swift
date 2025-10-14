import SwiftUI
import SwiftData

struct SubscriptionsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Subscription.nextPaymentDate, order: .forward)
    private var subs: [Subscription]
    
    @State private var viewModel = SubscriptionsViewModel()
    @State private var showingAdd = false
    @State private var search = ""
    
    var body: some View {
        NavigationStack {
            
        }
    }
}

#Preview {
    SubscriptionsView()
}
