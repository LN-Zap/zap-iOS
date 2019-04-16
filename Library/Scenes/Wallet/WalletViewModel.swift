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

    var network: Observable<Network?> {
        return lightningService.infoService.network
    }

    var nodeAlias: Signal<String?, NoError> {
        return lightningService.infoService.info
            .map { $0?.alias }
    }

    let balanceSegments: [WalletBalanceSegment]
    let circleGraphSegments = Observable<[CircleGraphView.Segment]>([])

    init(lightningService: LightningService) {
        self.lightningService = lightningService

        let balanceService = lightningService.balanceService
        balanceSegments = [
            WalletBalanceSegment(segment: .onChain, amount: balanceService.onChain.toSignal()),
            WalletBalanceSegment(segment: .lightning, amount: balanceService.lightning.toSignal()),
            WalletBalanceSegment(segment: .pending, amount: balanceService.pending.toSignal())
        ]

        super.init()

        combineLatest(balanceService.lightning, balanceService.onChain, balanceService.pending)
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
