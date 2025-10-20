import SwiftUI

struct SummaryHeader: View {
    let monthlyPence: Int
    let annualPence: Int
    let averageMonthlyPence: Int
    let nextSub: Subscription?
    let currency: Currency

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            monthlyTotal
            annualAverage

            if let nextSub {
                nextPaymentFooter(sub: nextSub)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var monthlyTotal: some View {
        Text("Monthly Total")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        
        Text(currency.format(pence: monthlyPence))
            .font(
                .system(
                    size: 38,
                    weight: .bold,
                    design: .rounded
                )
            )
            .padding(.bottom, 2)
    }
    
    @ViewBuilder
    private var annualAverage: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Annual")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(currency.format(pence: annualPence))
                    .font(.headline)
            }
            
            Spacer(minLength: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Avg / Sub (mo)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(currency.format(pence: averageMonthlyPence))
                    .font(.headline)
            }
        }
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private func nextPaymentFooter(sub: Subscription) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Next payment")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(sub.name) • \(sub.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    SummaryHeader(
        monthlyPence: 2000,
        annualPence: 200000,
        averageMonthlyPence: 2000,
        nextSub: makeSampleSubscriptions().first,
        currency: .gbp
    )
}
