//
//  NotificationManager.swift
//  151MoneyMap
//

import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound])
            } catch {
                return false
            }
        default:
            return false
        }
    }

    static func rescheduleRecurringReminders(templates: [RecurringTemplate]) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let recurringIds = pending.map(\.identifier).filter { $0.hasPrefix("recurring.") }
            center.removePendingNotificationRequests(withIdentifiers: recurringIds)

            for tpl in templates where tpl.isEnabled && tpl.type != .transfer {
                var dc = DateComponents()
                dc.day = tpl.dayOfMonth
                dc.hour = tpl.hour
                dc.minute = tpl.minute

                let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
                let content = UNMutableNotificationContent()
                content.title = "Recurring: \(tpl.name)"
                content.body = "Log \(tpl.type.rawValue.lowercased()) \(formatCurrency(tpl.amount)) — \(tpl.category.rawValue)"
                content.sound = .default

                let req = UNNotificationRequest(
                    identifier: "recurring.\(tpl.id.uuidString)",
                    content: content,
                    trigger: trigger
                )
                center.add(req)
            }
        }
    }
}
