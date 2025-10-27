import SwiftUI
import SwiftData

struct AddEditView: View {
    
    enum EditMode {
        case add
        case edit(Subscription)
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var priceText = ""
    @State private var cycle: Subscription.BillingCycle = .monthly
    @State private var date: Date = .now
    @State private var category = ""
    @State private var notes = ""
    @State private var hasCustomColor = false
    @State private var selectedColor: Color = .accentColor
    
    @FocusState private var focusedField: Field?
    enum Field {
        case name, price, category, notes, color
    }
    
    init(
        mode: EditMode,
        currency: Currency,
        onPersist: @escaping (Subscription) -> Void,
        onSaved: @escaping (Subscription) -> Void
    ) {
        self.mode = mode
        self.currency = currency
        self.onPersist = onPersist
        self.onSaved = onSaved
    }
    
    let mode: EditMode
    let currency: Currency
    /// Persist changes (insert on add, save on edit) — caller decides how.
    let onPersist: (Subscription) -> Void
    /// Post-save hook (e.g., schedule notifications)
    let onSaved: (Subscription) -> Void
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Name (e.g. Spotify)", text: $name)
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                
                HStack {
                    Text("Price")
                    Spacer()
                    TextField("9.99", text: $priceText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .price)
                }
                
                Picker("Billing cycle", selection: $cycle) {
                    ForEach(Subscription.BillingCycle.allCases) { cycle in
                        Text(cycle.display)
                            .tag(cycle)
                    }
                }
                
                DatePicker(
                    "Next payment",
                    selection: $date,
                    in: Date.now...,
                    displayedComponents: .date
                )
            }
            
            Section("Optional") {
                TextField("Category (e.g. Music)", text: $category)
                    .focused($focusedField, equals: .category)
                TextField("Notes", text: $notes, axis: .vertical)
                    .focused($focusedField, equals: .notes)
                Toggle("Use custom color", isOn: $hasCustomColor)
                if hasCustomColor {
                    ColorPicker(
                        "Color",
                        selection: $selectedColor,
                        supportsOpacity: false
                    )
                }
            }
            
            if let previewText = pricePreview {
                Section("Preview") {
                    HStack {
                        Text("Entered price")
                        Spacer()
                        Text(previewText)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear(perform: loadIfEditing)
    }
}

private extension AddEditView {
    
    var title: String  {
        switch mode {
        case .add: return "Add Subscription"
        case .edit: return "Edit Subscription"
        }
    }
    
    var pricePreview: String? {
        guard let pence = pricePence(from: priceText) else { return nil }
        return currency.format(pence: pence)
    }
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && pricePence(from: priceText) != nil
    }
    
    /// Accepts "9.99", "9,99", "9.", "9", etc. Returns minor units (pence).
    func pricePence(from text: String) -> Int? {
        let cleaned = text
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleaned.isEmpty else { return nil }
        // Avoid locale surprises: Decimal(string:) respects dot here.
        guard let decimal = Decimal(string: cleaned) else { return nil }
        return NSDecimalNumber(decimal: decimal * 100).intValue
    }
    
    func loadIfEditing() {
        if case .edit(let sub) = mode {
            name = sub.name
            priceText = currency.formatForEditing(pence: sub.pricePence)
            cycle = sub.billingCycle
            date = sub.nextPaymentDate
            category = sub.category ?? ""
            notes = sub.notes ?? ""
            
            if let hex = sub.colorHex, let loaded = Color(hex: hex) {
                hasCustomColor = true
                selectedColor = loaded
            } else {
                hasCustomColor = false
                selectedColor = .accentColor
            }
        }
    }
    
    func save() {
        guard let pence = pricePence(from: priceText) else { return }
        
        let colorHex: String? = hasCustomColor ? selectedColor.toHexRGB() : nil
        
        switch mode {
        case .add:
            let sub = Subscription(
                name: name.trimmed(),
                pricePence: pence,
                billingCycle: cycle,
                nextPaymentDate: date,
                category: category.trimmed().nilIfEmpty,
                notes: notes.trimmed().nilIfEmpty,
                colorHex: colorHex
            )
            onPersist(sub)
            onSaved(sub)
        case .edit(let sub):
            sub.name = name.trimmed()
            sub.pricePence = pence
            sub.billingCycle = cycle
            sub.nextPaymentDate = date
            sub.category = category.trimmed().nilIfEmpty
            sub.notes = notes.trimmed().nilIfEmpty
            sub.colorHex = colorHex
            onPersist(sub)
            onSaved(sub)
        }
        dismiss()
    }
}

private extension String {
    
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var nilIfEmpty: String? {
        trimmed().isEmpty ? nil : self
    }
}

#Preview("Add - GPB") {
    NavigationStack {
        AddEditView(
            mode: .add,
            currency: .gbp,
            onPersist: { _ in },
            onSaved: { _ in }
        )
    }
}

#Preview("Edit - Seeded") {
    let container = PreviewSwiftData.container(seed: true)
    let context = container.mainContext
    let sub = try! context.fetch(FetchDescriptor<Subscription>()).first!
    
    NavigationStack {
        AddEditView(
            mode: .edit(sub),
            currency: .gbp,
            onPersist: { _ in },
            onSaved: { _ in }
        )
        .modelContainer(container)
    }
}
