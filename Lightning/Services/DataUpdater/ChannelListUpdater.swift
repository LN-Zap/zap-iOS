//
//  Lightning
//
//  Created by 0 on 03.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import SwiftLnd

final class ChannelListUpdater: ListUpdater {
    private let api: LightningApi
    private let balanceService: BalanceService

    let transactions = MutableObservableArray<Transaction>()

    let open = MutableObservableArray<Channel>()
    let pending = MutableObservableArray<Channel>()
    let closed = MutableObservableArray<ChannelCloseSummary>()

    init(api: LightningApi, balanceService: BalanceService) {
        self.api = api
        self.balanceService = balanceService

        api.subscribeChannelEvents { [weak self] _ in
            self?.update()
        }
    }

    func update() {
        api.channels { [open] in
            if case .success(let channels) = $0 {
                open.replace(with: channels)
            }
        }

        api.pendingChannels { [pending, balanceService] in
            if case .success(let pendingChannels) = $0 {
                pending.replace(with: pendingChannels.channels)
                balanceService.lightningLimbo.value = pendingChannels.totalLimboBalance
            }
        }

        api.closedChannels { [closed] in
            if case .success(let closeSummaries) = $0 {
                closed.replace(with: closeSummaries)
            }
        }
    }
}
