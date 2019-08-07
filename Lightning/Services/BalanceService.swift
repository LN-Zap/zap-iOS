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
    public let lightningLimbo = Observable<Satoshi>(0) // force closing channels

    public let onChainTotal: Signal<Satoshi, Never>

    public let total: Signal<Satoshi, Never>
    public let totalPending: Signal<Satoshi, Never>

    init(api: LightningApi) {
        self.api = api

        onChainTotal = combineLatest(onChainConfirmed, onChainUnconfirmed) { $0 + $1 }
        totalPending = combineLatest(onChainUnconfirmed, lightningPendingOpenBalance, lightningLimbo) { $0 + $1 + $2 }
        total = combineLatest(onChainConfirmed, lightningChannelBalance) { $0 + $1 }
    }

    func update() {
        api.walletBalance { [weak self] result in
            if case .success(let walletBalance) = result {
                self?.onChainConfirmed.value = walletBalance.confirmedBalance
                self?.onChainUnconfirmed.value = walletBalance.unconfirmedBalance
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
