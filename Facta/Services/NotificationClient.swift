import Foundation
import UserNotifications
import ComposableArchitecture

struct NotificationClient {
    var requestAuthorization: () async throws -> Bool
    var scheduleDailyReminder: (Date) async throws -> Void
    var cancelDailyReminder: () async throws -> Void
    var scheduleFactReminder: (String, Date) async throws -> Void
    var cancelFactReminder: (String) async throws -> Void
    var getPendingNotifications: () async throws -> [UNNotificationRequest]
    var clearAllNotifications: () async throws -> Void
}

extension NotificationClient: DependencyKey {
    static let liveValue = NotificationClient(
        requestAuthorization: {
            let center = UNUserNotificationCenter.current()
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        },
        scheduleDailyReminder: { time in
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Dagens Fakta"
            content.body = "Kom och lär dig något nytt idag!"
            content.sound = .default
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "daily-reminder",
                content: content,
                trigger: trigger
            )
            
            try await center.add(request)
        },
        cancelDailyReminder: {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
        },
        scheduleFactReminder: { factTitle, date in
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Fakta påminnelse"
            content.body = "Kom ihåg: \(factTitle)"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: date.timeIntervalSinceNow,
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "fact-reminder-\(factTitle)",
                content: content,
                trigger: trigger
            )
            
            try await center.add(request)
        },
        cancelFactReminder: { factTitle in
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["fact-reminder-\(factTitle)"])
        },
        getPendingNotifications: {
            let center = UNUserNotificationCenter.current()
            return await center.pendingNotificationRequests()
        },
        clearAllNotifications: {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            center.removeAllDeliveredNotifications()
        }
    )
    
    static let testValue = NotificationClient(
        requestAuthorization: { true },
        scheduleDailyReminder: { _ in },
        cancelDailyReminder: { },
        scheduleFactReminder: { _, _ in },
        cancelFactReminder: { _ in },
        getPendingNotifications: { [] },
        clearAllNotifications: { }
    )
}

extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
