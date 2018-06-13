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

final class ChannelService {
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
    
    func close(_ channel: Channel) {
        let force = channel.state != .active
        api.closeChannel(channelPoint: channel.channelPoint, force: force) { [weak self] _ in
            self?.update()
        }
    }
    
    func alias(for remotePubkey: String, callback: @escaping (String?) -> Void) {
        api.nodeInfo(pubKey: remotePubkey) { result in
            if
                let nodeInfo = result.value,
                let alias = nodeInfo.node.alias,
                alias != "" {
                callback(alias)
            } else {
                callback(nil)
            }
        }
        
    }
}
