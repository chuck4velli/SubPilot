import SwiftUI
import SwiftData

struct SubscriptionsView: View {
    @AppStorage("selectedCurrencyCode") var selectedCurrencyCode = Currency.gbp.rawValue
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Subscription.nextPaymentDate, order: .forward)
    private var subs: [Subscription]
    
    @State private var viewModel = SubscriptionsViewModel()
    @State private var showingAdd = false
    @State private var search = ""
    
    @Namespace private var addEditSheet
    
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
                .searchable(
                    text: $search,
                    prompt: "Search name or category"
                )
                .sheet(isPresented: $showingAdd) {
                    NavigationStack {
                        AddEditView(
                            mode: .add,
                            currency: .gbp,
                            onPersist: { newSub in
                                context.insert( newSub); try? context.save()
                            },
                            onSaved: { _ in }
                        )
                    }
                    .navigationTransition(.zoom(sourceID: "plus", in: addEditSheet))
                }
                .navigationDestination(for: UUID.self) { id in
                    if let sub = subs.first(where: { $0.id == id }) {
                        AddEditView(
                            showDismiss: false,
                            mode: .edit(sub),
                            currency: selectedCurrency,
                            onPersist: { _ in
                                try? context.save()
                            },
                            onSaved: { updated in

                            }
                        )
                    } else {
                        Text("Not Found")
                    }
                }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    showingAdd = true
                }
            }
            .matchedTransitionSource(id: "plus", in: addEditSheet)
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "plus.circle.fill") {
                    showingAdd = true
                }
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
        if filteredSubs.isEmpty && search.isEmpty {
            emptyView()
        } else {
            List {
                Section {
                    SummaryHeader(
                        monthlyPence: viewModel.monthlyTotalPence(subs: filteredSubs),
                        annualPence: viewModel.annualTotalPence(subs: filteredSubs),
                        averageMonthlyPence: viewModel.averageMonthlyPence(subs: filteredSubs),
                        nextSub: viewModel.nextIncoming(subs: filteredSubs),
                        currency: selectedCurrency
                    )
                    
                    ForEach(filteredSubs) { sub in
                        NavigationLink(value: sub.id) {
                            SubscriptionRow(sub: sub, currency: selectedCurrency)
                                .swipeActions {
                                    if #available(iOS 26.0, *) {
                                        Button(role: .destructive) {
                                            context.delete(sub)
                                            try? context.save()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } else {
                                        Button("Delete", role: .destructive) {
                                            context.delete(sub)
                                            try? context.save()
                                        }
                                    }
                                }
                        }
                    }
                    
                    CategorySpendChart(
                        subs: filteredSubs,
                        currency: selectedCurrency
                    )
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        VStack(spacing: 12) {
            ContentUnavailableView(
                "No Subscriptions Yet",
                systemImage: "creditcard.and.numbers",
                description: Text("Track Netflix, Spotify, iCloud and more")
            )
            Button("Add Subscription") {
                showingAdd = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var filteredSubs: [Subscription] {
        viewModel.filter(subs: subs, query: search)
    }
}

#Preview("Empty") {
    SubscriptionsView()
        .modelContainer(PreviewSwiftData.container(seed: false))
}

#Preview("Seeded") {
    SubscriptionsView()
        .modelContainer(PreviewSwiftData.container(seed: true))
}
