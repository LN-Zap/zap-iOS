//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import SwiftBTC
import SwiftLnd

public final class BalanceService {
    private let api: LightningApi

    public let onChainConfirmed = Observable<Satoshi>(0)
    public let onChainUnconfirmed = Observable<Satoshi>(0)

    public let lightningChannelBalance = Observable<Satoshi>(0)
    public let lightningPendingOpenBalance = Observable<Satoshi>(0)

    public let onChainTotal = Observable<Satoshi>(0)
    public let totalPending: Signal<Satoshi, Never>

    // sum of funds stuck in force closing channels, set from `ChannelListUpdater`
    public let forceCloseLimboBalance = Observable<Satoshi>(0)

    init(api: LightningApi) {
        self.api = api

        totalPending = combineLatest(onChainUnconfirmed, lightningPendingOpenBalance, forceCloseLimboBalance) { $0 + $1 + $2 }
    }

    func update() {
        api.walletBalance { [weak self] result in
            if case .success(let walletBalance) = result {
                self?.onChainConfirmed.value = walletBalance.confirmedBalance
                self?.onChainUnconfirmed.value = walletBalance.unconfirmedBalance
                self?.onChainTotal.value = walletBalance.confirmedBalance + walletBalance.unconfirmedBalance
            }
        }

        api.channelBalance { [weak self] result in
            if case .success(let channelBalance) = result {
                self?.lightningChannelBalance.value = channelBalance.balance
                self?.lightningPendingOpenBalance.value = channelBalance.pendingOpenBalance
            }
        }
    }
}
