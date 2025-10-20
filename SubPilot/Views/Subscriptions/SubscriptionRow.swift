import SwiftUI

struct SubscriptionRow: View {
    let sub: Subscription
    let currency: Currency

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: sub.colorHex) ?? .accentColor.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(sub.name.prefix(1))
                        .font(.headline)
                )
            
            VStack(alignment: .leading) {
                Text(sub.name)
                    .font(.headline)
                Text("\(sub.billingCycle.display) • \(sub.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            Text(currency.format(pence: sub.pricePence))
                .font(.headline)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    SubscriptionRow(
        sub: makeSampleSubscriptions().first!,
        currency: .gbp
    )
}
