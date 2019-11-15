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
    
    let syncViewModel: SyncViewModel
    let balanceDetailViewModel: BalanceDetailViewModel
    
    var shouldHideChannelEmptyState: Signal<Bool, Never>
    var didDismissChannelEmptyState = Observable(false)
    
    init(lightningService: LightningService) {
        self.lightningService = lightningService
        self.syncViewModel = SyncViewModel(lightningService: lightningService)
        
        let balanceService = lightningService.balanceService
        self.balanceDetailViewModel = BalanceDetailViewModel(balanceService: balanceService)
        
        self.shouldHideEmptyWalletState = lightningService.balanceService.totalBalance
            .map { $0 > 0 }
            .distinctUntilChanged()

        self.shouldHideChannelEmptyState = combineLatest(
            lightningService.balanceService.onChainConfirmed,
            lightningService.channelService.all,
            didDismissChannelEmptyState
        )
            .map { !($0 > 0 && $1.collection.isEmpty) || $2 }
            .distinctUntilChanged()
        
        super.init()
    }
}
