//
//  Library
//
//  Created by 0 on 16.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning

enum NotificationConfigurator {
    static func configure() {
        NotificationScheduler.shared.configurations = [
            NotificationScheduler.Configuration(daysLeft: 2, title: L10n.Notification.Sync.title, body: L10n.Notification.Sync.Day12.body),
            NotificationScheduler.Configuration(daysLeft: 1, title: L10n.Notification.Sync.title, body: L10n.Notification.Sync.Day13.body),
            NotificationScheduler.Configuration(daysLeft: 0, title: L10n.Notification.Sync.title, body: L10n.Notification.Sync.Day14.body)
        ]
    }
}
