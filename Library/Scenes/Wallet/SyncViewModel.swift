//
//  Library
//
//  Created by 0 on 23.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning
import ReactiveKit

final class SyncViewModel {
    let lightningService: LightningService
    var syncPercentageEstimator: SyncPercentageEstimator?

    var percentSignal: Signal<Double, Never> {
        return combineLatest(lightningService.infoService.blockHeight, lightningService.infoService.bestHeaderDate, lightningService.infoService.blockChainHeight) { [weak self] lndBlockHeigh, lndHeaderDate, maxBlockHeight -> Double in
            guard
                let lndBlockHeigh = lndBlockHeigh,
                let lndHeaderDate = lndHeaderDate,
                let maxBlockHeight = maxBlockHeight
                else { return 0 }

            if self?.syncPercentageEstimator == nil {
                self?.syncPercentageEstimator = SyncPercentageEstimator(initialLndBlockHeight: lndBlockHeigh, initialHeaderDate: lndHeaderDate)
            }

            let percentage = self?.syncPercentageEstimator?.percentage(lndBlockHeight: lndBlockHeigh, lndHeaderDate: lndHeaderDate, maxBlockHeight: maxBlockHeight) ?? 0
            guard percentage.isNormal else { return 0 }

            return min(percentage, 1)
        }
    }

    var isSyncing: Signal<Bool, Never> {
        return lightningService.infoService.walletState
            .map { $0 == .syncing }
    }

    init(lightningService: LightningService) {
        self.lightningService = lightningService
    }
}
