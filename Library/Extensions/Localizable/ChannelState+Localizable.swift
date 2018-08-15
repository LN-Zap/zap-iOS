//
//  Library
//
//  Created by Otto Suess on 30.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

extension ChannelState: Localizable {
    public var localized: String {
        switch self {
        case .active:
            return "channel.state.active".localized
        case .inactive:
            return "channel.state.inactive".localized
        case .opening:
            return "channel.state.opening".localized
        case .closing:
            return "channel.state.closing".localized
        case .forceClosing:
            return "channel.state.force_closing".localized
        }
    }
}
