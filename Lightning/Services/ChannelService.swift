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
import SwiftLnd

public final class ChannelService {
    private let api: LightningApiProtocol

    let all: Signal<[Channel], NoError>
    public let open = Observable<[Channel]>([])
    public let pending = Observable<[Channel]>([])
    public let closed = Observable<[ChannelCloseSummary]>([])
    
    init(api: LightningApiProtocol) {
        self.api = api
        
        all = combineLatest(open, pending) {
            $0 as [Channel] + $1 as [Channel]
        }
    }

    public func update() {
        api.channels { [open] result in
            open.value = result.value ?? []
        }
        
        api.pendingChannels { [pending] result in
            pending.value = result.value ?? []
        }
        
        api.closedChannels { [closed] result in
            closed.value = result.value ?? []
        }
    }
    
    public func open(pubKey: String, host: String, amount: Satoshi, completion: @escaping (SwiftLnd.Result<ChannelPoint>) -> Void) {
        api.peers { [weak self, api] peers in
            if peers.value?.contains(where: { $0.pubKey == pubKey }) == true {
                self?.openConnectedChannel(pubKey: pubKey, amount: amount, completion: completion)
            } else {
                api.connect(pubKey: pubKey, host: host) { result in
                    if let error = result.error {
                        completion(.failure(error))
                    } else {
                        self?.openConnectedChannel(pubKey: pubKey, amount: amount, completion: completion)
                    }
                }
            }
        }
    }
    
    private func openConnectedChannel(pubKey: String, amount: Satoshi, completion: @escaping (SwiftLnd.Result<ChannelPoint>) -> Void) {
        api.openChannel(pubKey: pubKey, amount: amount) { [weak self] in
            self?.update()
            completion($0)
        }
    }
    
    public func close(_ channel: Channel, completion: @escaping (SwiftLnd.Result<CloseStatusUpdate>) -> Void) {
        let force = channel.state != .active
        api.closeChannel(channelPoint: channel.channelPoint, force: force) { [weak self] in
            self?.update()
            completion($0)
        }
    }
    
    func node(for remotePubkey: String, completion: @escaping (LightningNode?) -> Void) {
        api.nodeInfo(pubKey: remotePubkey) { result in
            completion(result.value?.node)
        }
    }
}
