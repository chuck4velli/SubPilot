import UserNotifications
import Observation

@MainActor
@Observable
final class SubscriptionsViewModel {
    // MARK: - Filtering
    func filter(subs: [Subscription], query: String) -> [Subscription] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return subs }
        return subs.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
            || ($0.category ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }
    
    // MARK: - Totals
    func monthlyTotalPence(subs: [Subscription]) -> Int {
        subs.reduce(0) { $0 + $1.monthlyEquivalentPence }
    }
    
    func annualTotalPence(subs: [Subscription]) -> Int {
        monthlyTotalPence(subs: subs) * 12
    }
    
    func averageMonthlyPence(subs: [Subscription]) -> Int {
        let count = subs.count
        guard count > 0 else { return 0 }
        let total = monthlyTotalPence(subs: subs)
        return (total + count / 2) / count // Rounded to nearest
    }
    
    func nextIncoming(subs: [Subscription]) -> Subscription? {
        subs.min(by: { $0.nextPaymentDate < $1.nextPaymentDate })
    }
    
    // MARK: - Notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    func scheduleReminder(for sub: Subscription) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [sub.id.uuidString])
        
        let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: sub.nextPaymentDate) ?? sub.nextPaymentDate
        guard triggerDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming \(sub.name)"
        content.body = "Renews \(sub.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))"
        content.sound = .default
        
        var date = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        date.hour = 9
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: sub.id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func cancelReminder(for sub: Subscription) {
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: [sub.id.uuidString])
    }
}

