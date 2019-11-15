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

public final class BalanceService: NSObject {
    private let api: LightningApi

    public let onChainConfirmed = Observable<Satoshi>(0)
    public let onChainUnconfirmed = Observable<Satoshi>(0)

    public let lightningChannelBalance = Observable<Satoshi>(0)
    public let lightningPendingOpenBalance = Observable<Satoshi>(0)

    public let onChainTotal = Observable<Satoshi>(0)
    public let totalPending: Signal<Satoshi, Never>
    
    public let totalBalance = Observable<Satoshi>(0)

    // sum of funds stuck in force closing channels, set from `ChannelListUpdater`
    public let forceCloseLimboBalance = Observable<Satoshi>(0)

    private let didLoadWalletBalance = Observable<Bool>(false)
    private let didLoadChannelBalance = Observable<Bool>(false)
    public let didLoadBalances: Signal<Bool, Never>
    
    init(api: LightningApi) {
        self.api = api
        
        totalPending = combineLatest(onChainUnconfirmed, lightningPendingOpenBalance, forceCloseLimboBalance) { $0 + $1 + $2 }
        didLoadBalances = combineLatest(didLoadWalletBalance, didLoadChannelBalance) { $0 && $1 }
        
        super.init()
        
        combineLatest(lightningChannelBalance, onChainConfirmed, totalPending)
            .distinctUntilChanged { $0 != $1 }
            .observeNext { [weak self] in
                let (lightningBalance, onChainBalance, pendingBalance) = $0
                
                self?.totalBalance.value = lightningBalance + onChainBalance + pendingBalance
            }.dispose(in: reactive.bag)
    }

    func update() {
        api.walletBalance { [weak self] result in
            if case .success(let walletBalance) = result {
                self?.onChainConfirmed.value = walletBalance.confirmedBalance
                self?.onChainUnconfirmed.value = walletBalance.unconfirmedBalance
                self?.onChainTotal.value = walletBalance.confirmedBalance + walletBalance.unconfirmedBalance
                
                self?.didLoadWalletBalance.value = true
            }
        }

        api.channelBalance { [weak self] result in
            if case .success(let channelBalance) = result {
                self?.lightningChannelBalance.value = channelBalance.balance
                self?.lightningPendingOpenBalance.value = channelBalance.pendingOpenBalance
                
                self?.didLoadChannelBalance.value = true
            }
        }
    }
}
