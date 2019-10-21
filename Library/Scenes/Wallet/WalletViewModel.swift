//
//  Library
//
//  Created by 0 on 08.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit
import SwiftBTC

final class WalletViewModel: NSObject {
    let lightningService: LightningService
    let shouldHideEmptyWalletState: Signal<Bool, Never>
    let balanceSegments: [WalletBalanceSegment]
    let circleGraphSegments = Observable<[CircleGraphView.Segment]>([])

    var syncViewModel: SyncViewModel

    var network: Observable<Network?> {
        return lightningService.infoService.network
    }

    var nodeAlias: Signal<String?, Never> {
        return lightningService.infoService.info
            .map { $0?.alias }
    }

    init(lightningService: LightningService) {
        self.lightningService = lightningService
        self.syncViewModel = SyncViewModel(lightningService: lightningService)
        
        let balanceService = lightningService.balanceService
        
        self.balanceSegments = [
            WalletBalanceSegment(segment: .onChain, amount: balanceService.onChainConfirmed.toSignal()),
            WalletBalanceSegment(segment: .lightning, amount: balanceService.lightningChannelBalance.toSignal()),
            WalletBalanceSegment(segment: .pending, amount: balanceService.totalPending)
        ]
        
        self.shouldHideEmptyWalletState = lightningService.balanceService.totalBalance
            .map { $0 > 0 }
            .distinctUntilChanged()

        super.init()
        
        combineLatest(balanceService.lightningChannelBalance, balanceService.onChainConfirmed, balanceService.totalPending)
            .distinctUntilChanged { $0 != $1 }
            .observeNext { [weak self] in
                let (lightningBalance, onChainBalance, pendingBalance) = $0

                self?.circleGraphSegments.value = [
                    CircleGraphView.Segment(amount: onChainBalance, color: Segment.onChain.color),
                    CircleGraphView.Segment(amount: lightningBalance, color: Segment.lightning.color),
                    CircleGraphView.Segment(amount: pendingBalance, color: Segment.pending.color)
                ]
            }
            .dispose(in: reactive.bag)
    }
}
