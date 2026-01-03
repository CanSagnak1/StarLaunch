//
//  NotificationManager.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 2.01.2026.
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    var isAuthorized: Bool = false

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted

                if granted {
                    self?.registerCategories()
                }

                completion(granted)
            }
        }
    }

    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                self?.isAuthorized = isAuthorized
                completion(isAuthorized)
            }
        }
    }

    private func registerCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_LAUNCH",
            title: "View Details",
            options: .foreground
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: .destructive
        )

        let launchCategory = UNNotificationCategory(
            identifier: "LAUNCH_ALERT",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([launchCategory])
    }

    func scheduleNotification(for launch: LaunchItem, minutesBefore: Int = 15) {
        guard isAuthorized else {
            return
        }

        let formatter = ISO8601DateFormatter()
        guard let launchDate = formatter.date(from: launch.windowStart) else {
            return
        }

        let notificationDate = launchDate.addingTimeInterval(TimeInterval(-minutesBefore * 60))

        guard notificationDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "🚀 Launch Alert!"
        content.body = "\(launch.name) is launching in \(minutesBefore) minutes!"
        content.sound = .default
        content.categoryIdentifier = "LAUNCH_ALERT"
        content.userInfo = [
            "launchID": launch.id,
            "launchName": launch.name,
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "launch_\(launch.id)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
        }
    }

    func cancelNotification(for launchID: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["launch_\(launchID)"]
        )

    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()

    }

    func isNotificationScheduled(for launchID: String, completion: @escaping (Bool) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            let isScheduled = requests.contains { $0.identifier == "launch_\(launchID)" }
            DispatchQueue.main.async {
                completion(isScheduled)
            }
        }
    }

    func getScheduledNotifications(completion: @escaping ([String]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            let launchIDs = requests.compactMap { request -> String? in
                guard request.identifier.hasPrefix("launch_") else { return nil }
                return String(request.identifier.dropFirst(7))
            }
            DispatchQueue.main.async {
                completion(launchIDs)
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let launchID = userInfo["launchID"] as? String {
            NotificationCenter.default.post(
                name: .openLaunchDetail,
                object: nil,
                userInfo: ["launchID": launchID]
            )
        }

        completionHandler()
    }
}

extension Notification.Name {
    static let openLaunchDetail = Notification.Name("openLaunchDetail")
}
