import Foundation

enum Currency: String, Codable, CaseIterable, Identifiable {
    case gbp, eur, usd
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .gbp: return "£"
        case .eur: return "€"
        case .usd: return "$"
        }
    }
    
    /// Format minor units (pence/cents) for display.
    func format(pence: Int) -> String {
        let amount = Double(pence) / 100.00
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = symbol
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: amount)) ?? "\(symbol)\(String(format: "%.2f", amount))"
    }
    
    /// For populating text fields when editing a price.
    func formatForEditing(pence: Int) -> String {
        String(format: "%.2f", Double(pence) / 100.00)
    }
}
