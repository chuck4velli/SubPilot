import Foundation

struct CategorySpend: Identifiable {
    let id = UUID()
    let category: String
    let totalPence: Int
}
