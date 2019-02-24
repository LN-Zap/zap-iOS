//
//  Library
//
//  Created by Otto Suess on 05.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class SyncPercentageEstimator {
    let initialLndBlockHeight: Int
    let initialHeaderDate: Date

    init(initialLndBlockHeight: Int, initialHeaderDate: Date) {
        self.initialLndBlockHeight = initialLndBlockHeight
        self.initialHeaderDate = initialHeaderDate
    }

    func percentage(lndBlockHeight: Int, lndHeaderDate: Date, maxBlockHeight: Int) -> Double {
        // blocks
        let blocksToSync = maxBlockHeight - initialLndBlockHeight
        let blocksRemaining = maxBlockHeight - lndBlockHeight
        let blocksDone = blocksToSync - blocksRemaining

        // filters
        let filtersToSync = Int(abs(initialHeaderDate.timeIntervalSinceNow / 10))
        let filtersRemaining = Int(abs(lndHeaderDate.timeIntervalSinceNow / 10))
        let filtersDone = filtersToSync - filtersRemaining

        // totals
        let totalToSync = blocksToSync + filtersToSync
        let done = blocksDone + filtersDone
        return Double(done) / Double(totalToSync)
    }
}
