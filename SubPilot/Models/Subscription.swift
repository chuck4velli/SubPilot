import Foundation
import SwiftData

@Model
final class Subscription {
    @Attribute(.unique) var id: UUID
    var name: String
    /// Price in minor units (pence). Example: £9.99 -> 999
    var pricePence: Int
    var billingCycle: BillingCycle
    var nextPaymentDate: Date
    var category: String?
    var notes: String?
    /// Optional brand color (hex). Purely cosmetic
    var colorHex: String?
    
    init(
        id: UUID = .init(),
        name: String,
        pricePence: Int,
        billingCycle: BillingCycle,
        nextPaymentDate: Date,
        category: String? = nil,
        notes: String? = nil,
        colorHex: String? = nil
    ) {
        self.id = id
        self.name = name
        self.pricePence = pricePence
        self.billingCycle = billingCycle
        self.nextPaymentDate = nextPaymentDate
        self.category = category
        self.notes = notes
        self.colorHex = colorHex
    }
    
    /// Returns a monthly-equivalent price in pence based on the billing cycle.
    var monthlyEquivalentPence: Int {
        switch billingCycle {
        case .weekly:
            let numerator = pricePence * 52
            // +6 ensures rounding half-up
            return (numerator + 6) / 12
        case .monthly:
            return pricePence
        case .quarterly:
            // (price / 3) rounded
            return (pricePence + 1) / 3
        case .yearly:
            // (price / 12) rounded
            return (pricePence + 6) / 12
        }
    }
}

extension Subscription {
    enum BillingCycle: String, Codable, CaseIterable, Identifiable {
        case weekly, monthly, quarterly, yearly
        var id: String { rawValue }
        
        var display: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .quarterly: return "Quarterly"
            case .yearly: return "Yearly"
            }
        }
    }
}
