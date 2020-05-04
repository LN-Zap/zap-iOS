//
//  Lightning
//
//  Created by 0 on 15.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import Logger
import ReactiveKit
import SwiftLnd
import UserNotifications

final class NotificationScheduler: NSObject {
    struct Configuration {
        let daysLeft: Int
        let title: String
        let body: String
    }

    private let configurations: [Configuration]

    init(configurations: [Configuration]) {
        self.configurations = configurations
    }

    static var needsAuthorization: Bool {
        let center = UNUserNotificationCenter.current()
        var result = false
        let group = DispatchGroup()
        group.enter()

        center.getNotificationSettings { settings in
            result = settings.authorizationStatus != .authorized
            group.leave()
        }

        group.wait()

        return result
    }

    static func requestAuthorization(completion: @escaping (() -> Void)) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { _, _ in
            completion()
        }
    }

    func listenToChannelUpdates(lightningService: LightningService) {
        guard lightningService.connection == .local else { return }
        // TODO: listen to pending channels. when there is a pending channel
        // schedule a notification at current date + 2016 blocks (2 weeks)
        // (the current default csv_delay) also don't hardcode magic numbers.
        combineLatest(lightningService.channelService.open, lightningService.infoService.bestHeaderDate) { ($0.collection, $1) }
            .debounce(for: 2)
            .observeNext { [weak self] in
                self?.schedule(for: $0.0, bestHeaderDate: $0.1)
            }
            .dispose(in: reactive.bag)
    }

    private func schedule(for channels: [OpenChannel], bestHeaderDate: Date?) {
        guard let bestHeaderDate = bestHeaderDate else { return }

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()

        notificationCenter.getNotificationSettings { settings in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else { return }

            notificationCenter.removeAllPendingNotificationRequests()

            let csvDelays = channels
                .filter { $0.localBalance > 0 } // we only care about channels where we can lose some money.
                .map { $0.csvDelay }
            Logger.info(csvDelays, customPrefix: "💌")

            if let minCsvDelay = csvDelays.min() {
                let day: TimeInterval = 24 * 60 * 60
                let csvTimeInterval = TimeInterval(minCsvDelay) * 10 * 60

                for configuration in self.configurations {
                    let timestamp = csvTimeInterval - TimeInterval(configuration.daysLeft) * day
                    let date = bestHeaderDate + timestamp

                    if date > Date() {
                        self.addNotification(date: date, title: configuration.title, body: configuration.body)
                    }
                }
            }
        }
    }

    private func addNotification(date: Date, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSince1970, repeats: false)

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let error = error {
                Logger.error("Error adding notification: \(error)", customPrefix: "💌")
            } else {
                Logger.info("scheduled notification on \(date): \"\(request.content.body)\"", customPrefix: "💌")
            }
        }
    }
}
