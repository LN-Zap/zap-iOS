//
//  Library
//
//  Created by 0 on 14.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit

final class BalanceDetailViewModel: NSObject {
    let balanceSegments: [WalletBalanceSegment]
    let circleGraphSegments = Observable<[CircleGraphView.Segment]>([])
    
    init(balanceService: BalanceService) {
        self.balanceSegments = [
            WalletBalanceSegment(segment: .onChain, amount: balanceService.onChainConfirmed.toSignal()),
            WalletBalanceSegment(segment: .lightning, amount: balanceService.lightningChannelBalance.toSignal()),
            WalletBalanceSegment(segment: .pending, amount: balanceService.totalPending)
        ]
        
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
