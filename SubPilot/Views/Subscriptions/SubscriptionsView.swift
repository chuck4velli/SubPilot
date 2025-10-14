import SwiftUI
import SwiftData

struct SubscriptionsView: View {
    @AppStorage("selectedCurrencyCode") var selectedCurrencyCode = Currency.gbp.rawValue
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Subscription.nextPaymentDate, order: .forward)
    private var subs: [Subscription]
    
    @State private var viewModel = SubscriptionsViewModel()
    @State private var search = ""
    
    private var selectedCurrency: Currency {
        Currency(rawValue: selectedCurrencyCode) ?? .gbp
    }
    private var selectedCurrencyBinding: Binding<Currency> {
        Binding(
            get: { Currency(rawValue: selectedCurrencyCode) ?? .gbp },
            set: { selectedCurrencyCode = $0.rawValue }
        )
    }
    
    var body: some View {
        NavigationStack {
            content()
                .navigationTitle("Subscriptions")
                .toolbar {
                    toolbarContent
                }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                // TODO: Add subscription
            } label: {
                Image(systemName: "plus.circle.fill")
            }
        }
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Currency", selection: selectedCurrencyBinding) {
                    ForEach(Currency.allCases) { currency in
                        Text(currency.symbol).tag(currency)
                    }
                }
            } label: {
                Text(selectedCurrency.symbol)
                    .font(.headline)
            }
        }
    }
    
    @ViewBuilder
    private func content() -> some View {
        if filteredSubs.isEmpty {
            emptyView()
        } else {
            List {
                Section {
                    SummaryHeader(
                        monthlyPence: viewModel.monthlyTotalPence(subs: filteredSubs),
                        annualPence: viewModel.annualTotalPence(subs: filteredSubs),
                        averageMonthlyPence: viewModel.averageMonthlyPence(subs: filteredSubs),
                        nextSubscription: viewModel.nextIncoming(subs: filteredSubs),
                        currency: selectedCurrency
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
        }
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        VStack(spacing: 12) {
            ContentUnavailableView(
                "No Subscriptions Yet",
                systemImage: "creditcard.and.123.circle",
                description: Text("Track Netflix, Spotify, iCloud and more")
            )
            Button("Add Subscription") {
                // TODO: Add subcription
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Filtering
    private var filteredSubs: [Subscription] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return subs }
        return subs.filter {
            $0.name.localizedCaseInsensitiveContains(query)
            || ($0.category ?? "").localizedCaseInsensitiveContains(query)
        }
    }
}

#Preview {
    SubscriptionsView()
}
