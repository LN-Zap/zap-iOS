//
//  Library
//
//  Created by 0 on 08.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import SwiftBTC

enum Segment: Localizable {
    case lightning
    case onChain
    case pending

    var localized: String {
        switch self {
        case .lightning:
            return L10n.Scene.Wallet.Detail.lightning
        case .onChain:
            return L10n.Scene.Wallet.Detail.onChain
        case .pending:
            return L10n.Scene.Wallet.Detail.pending
        }
    }

    var color: UIColor {
        switch self {
        case .lightning:
            return UIColor.Zap.purple
        case .onChain:
            return UIColor.Zap.lightningOrange
        case .pending:
            return UIColor.Zap.gray
        }
    }
}

struct WalletBalanceSegment {
    let segment: Segment
    let amount: Signal<Satoshi, Never>
}
