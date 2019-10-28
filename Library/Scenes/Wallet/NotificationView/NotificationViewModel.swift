//
//  Library
//
//  Created by 0 on 28.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class NotificationViewModel {
    let title: String
    let message: String
    let action: () -> Void
    
    internal init(title: String, message: String, action: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.action = action
    }
}
