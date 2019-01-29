//
//  Library
//
//  Created by Otto Suess on 30.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

extension ChannelState: Localizable {
    public var localized: String {
        switch self {
        case .active:
            return L10n.Channel.State.active
        case .inactive:
            return L10n.Channel.State.inactive
        case .opening:
            return L10n.Channel.State.opening
        case .closing:
            return L10n.Channel.State.closing
        case .forceClosing:
            return L10n.Channel.State.forceClosing
        case .waitingClose:
            return L10n.Channel.State.waitingClose
        }
    }
}
