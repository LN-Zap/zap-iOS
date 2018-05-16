//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

final class Channels {
    private let api: LightningProtocol

    let all: Signal<[Channel], NoError>
    let open = Observable<[Channel]>([])
    let pending = Observable<[Channel]>([])

    init(api: LightningProtocol) {
        self.api = api
        
        all = combineLatest(open, pending) {
            return $0 as [Channel] + $1 as [Channel]
        }
    }

    func update() {
        api.channels { [open] result in
            open.value = result.value ?? []
        }
        
        api.pendingChannels { [pending] result in
            pending.value = result.value ?? []
        }
    }
    
    func open(pubKey: String, host: String, amount: Satoshi, completion: @escaping () -> Void) {
        api.peers { [weak self, api] peers in
            if peers.value?.contains(where: { $0.pubKey == pubKey }) == true {
                self?.openConnectedChannel(pubKey: pubKey, amount: amount, completion: completion)
            } else {
                api.connect(pubKey: pubKey, host: host) {
                    guard $0.error != nil else { return }
                    self?.openConnectedChannel(pubKey: pubKey, amount: amount, completion: completion)
                }
            }
        }
    }
    
    private func openConnectedChannel(pubKey: String, amount: Satoshi, completion: @escaping () -> Void) {
        api.openChannel(pubKey: pubKey, amount: amount) { [weak self] _ in
            self?.update()
            completion()
        }
    }
    
    func close(channelPoint: String, completion: @escaping () -> Void) {
        api.closeChannel(channelPoint: channelPoint) { [weak self] _ in
            self?.update()
            completion()
        }
    }
}
