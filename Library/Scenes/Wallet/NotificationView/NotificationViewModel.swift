//
//  Library
//
//  Created by 0 on 28.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class NotificationViewModel {
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    internal init(message: String, actionTitle: String, action: @escaping () -> Void) {
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
}
