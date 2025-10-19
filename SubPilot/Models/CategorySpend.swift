import Foundation

struct CategorySpend: Identifiable, Equatable {
    let id = UUID()
    let colorHex: String
    let category: String
    let totalPence: Int
}
