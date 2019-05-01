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

    let transactions = MutableObservableArray<Transaction>()

    let open = MutableObservableArray<Channel>()
    let pending = MutableObservableArray<Channel>()
    let closed = MutableObservableArray<ChannelCloseSummary>()

    init(api: LightningApi) {
        self.api = api

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

        api.pendingChannels { [pending] in
            if case .success(let channels) = $0 {
                pending.replace(with: channels)
            }
        }

        api.closedChannels { [closed] in
            if case .success(let closeSummaries) = $0 {
                closed.replace(with: closeSummaries)
            }
        }
    }
}
