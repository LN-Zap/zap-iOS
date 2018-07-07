//
//  Library
//
//  Created by Otto Suess on 07.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

extension CloseType: Localizable {
    public var localized: String {
        switch self {
        case .cooperativeClose:
            return "close_type.cooperative_close".localized
        case .localForceClose:
            return "close_type.local_force_close".localized
        case .remoteForceClose:
            return "close_type.remote_force_close".localized
        case .breachClose:
            return "close_type.breach_close".localized
        case .fundingCanceled:
            return "close_type.funding_canceled".localized
        case .unknown:
            return "close_type.unknown".localized
        }
    }
}
