import Charts
import SwiftUI

struct CategorySpendChart: View {
    let subs: [Subscription]
    let currency: Currency
    let topNumber: Int = 5
    
    private var data: [CategorySpend] {
        let grouped = Dictionary(grouping: subs) {
            ($0.category?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? $0.category! : "Other"
        }
        let totals = grouped.map { category, items in
            let colorHex = items.first?.colorHex ?? "#000000"
            return CategorySpend(
                colorHex: colorHex,
                category: category,
                totalPence: items.reduce(0) { $0 + $1.monthlyEquivalentPence
                }
            )
        }
        return totals.sorted { $0.totalPence > $1.totalPence }.prefix(topNumber).map { $0 }
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Spend by Category (Monthly Eq.)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            if data.isEmpty {
                Text("No data yet")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Amount", Double(item.totalPence) / 100.0),
                        y: .value("Category", item.category)
                    )
                    .foregroundStyle(Color(hex: item.colorHex) ?? .clear)
                    .annotation(position: .trailing, alignment: .leading) {
                        Text(currency.format(pence: item.totalPence))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .currency(code: currency.rawValue.uppercased()))
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .leading)
                }
                .frame(height: max(140, CGFloat(data.count) * 28))                
            }
            Divider()
                .padding(.top, 2)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CategorySpendChart(
        subs: makeSampleSubscriptions(),
        currency: .gbp
    )
}
