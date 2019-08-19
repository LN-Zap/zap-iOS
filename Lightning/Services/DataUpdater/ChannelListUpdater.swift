//
//  Lightning
//
//  Created by 0 on 03.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import ReactiveKit
import SwiftLnd

final class ChannelListUpdater: NSObject, ListUpdater {
    private let api: LightningApi
    private let balanceService: BalanceService

    let open = MutableObservableArray<Channel>()
    let pending = MutableObservableArray<Channel>()

    let all = MutableObservableArray<Channel>()

    let closed = MutableObservableArray<ChannelCloseSummary>()

    init(api: LightningApi, balanceService: BalanceService) {
        self.api = api
        self.balanceService = balanceService

        super.init()

        api.subscribeChannelEvents { [weak self] in
            Logger.info("new channel event \($0)", customPrefix: "🏊‍♂️")
            self?.update()
        }

        combineLatest(open, pending) { $0.collection + $1.collection }
            .distinctUntilChanged()
            .observeNext { [weak self] in self?.all.replace(with: $0, performDiff: true) }
            .dispose(in: reactive.bag)
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
                balanceService.forceCloseLimboBalance.value = pendingChannels.forceCloseLimboBalance
            }
        }

        api.closedChannels { [closed] in
            if case .success(let closeSummaries) = $0 {
                closed.replace(with: closeSummaries)
            }
        }
    }
}
