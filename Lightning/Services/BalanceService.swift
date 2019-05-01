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

    public let onChain = Observable<Satoshi>(0)
    public let lightning = Observable<Satoshi>(0)
    public let pending = Observable<Satoshi>(0)

    public let total: Signal<Satoshi, NoError>

    init(api: LightningApi) {
        self.api = api
        total = combineLatest(onChain, lightning) { $0 + $1 }
    }

    func update() {
        DispatchQueue(label: "updateBalance").async { [weak self] in
            let group = DispatchGroup()
            var pending: Satoshi = 0

            group.enter()
            self?.api.walletBalance { result in
                if case .success(let walletBalance) = result {
                    self?.onChain.value = walletBalance.confirmedBalance
                    pending += walletBalance.unconfirmedBalance
                }
                group.leave()
            }

            group.enter()
            self?.api.channelBalance { result in
                if case .success(let channelBalance) = result {
                    self?.lightning.value = channelBalance.balance
                    pending += channelBalance.pendingOpenBalance
                }
                group.leave()
            }

            group.wait()

            self?.pending.value = pending
        }
    }
}
