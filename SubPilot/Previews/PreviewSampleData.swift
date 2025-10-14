import Foundation

func makeSampleSubscriptions() -> [Subscription] {
    let today = Date()
    let calendar = Calendar.current
    
    return [
        Subscription(
            name: "Spotify",
            pricePence: 999,
            billingCycle: .monthly,
            nextPaymentDate: calendar.date(byAdding: .day, value: 12, to: today)!,
            category: "Music",
            notes: "Student plan",
            colorHex: "#1DB954"
        ),
        Subscription(
            name: "Netflix",
            pricePence: 1599,
            billingCycle: .monthly,
            nextPaymentDate: calendar.date(byAdding: .day, value: 3, to: today)!,
            category: "Entertainment",
            notes: nil,
            colorHex: "#E50914"
        ),
        Subscription(
            name: "iCloud+",
            pricePence: 289,
            billingCycle: .monthly,
            nextPaymentDate: calendar.date(byAdding: .day, value: 20, to: today)!,
            category: "Utilities",
            notes: "200GB",
            colorHex: "#0A84FF"
        ),
        Subscription(
            name: "Amazon Prime",
            pricePence: 9599,
            billingCycle: .yearly,
            nextPaymentDate: calendar.date(byAdding: .day, value: 180, to: today)!,
            category: "Shopping",
            notes: nil,
            colorHex: "#146EB4"
        )
    ]
}
