//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import ReactiveKit
import SwiftBTC
import SwiftLnd

public final class ChannelService {
    private let api: LightningApiProtocol
    private let channelListUpdater: ChannelListUpdater

    public var open: MutableObservableArray<Channel> {
        return channelListUpdater.open
    }

    public var pending: MutableObservableArray<Channel> {
        return channelListUpdater.pending
    }

    public var maxRemoteBalance: Satoshi {
        var maxRemoteBalance: Satoshi = 0
        for channel in channelListUpdater.open.array where channel.remoteBalance > maxRemoteBalance {
            maxRemoteBalance = channel.remoteBalance
        }
        return maxRemoteBalance
    }

    init(api: LightningApiProtocol, channelListUpdater: ChannelListUpdater) {
        self.api = api
        self.channelListUpdater = channelListUpdater
    }

    public func open(lightningNodeURI: LightningNodeURI, amount: Satoshi, completion: @escaping (Swift.Result<ChannelPoint, LndApiError>) -> Void) {
        api.peers { [weak self, api] result in
            if (try? result.get())?.contains(where: { $0.pubKey == lightningNodeURI.pubKey }) == true {
                self?.openConnectedChannel(pubKey: lightningNodeURI.pubKey, amount: amount, completion: completion)
            } else {
                api.connect(pubKey: lightningNodeURI.pubKey, host: lightningNodeURI.host) { result in
                    if case .failure(let error) = result {
                        completion(.failure(LndApiError.localizedError(error.localizedDescription)))
                    } else {
                        self?.openConnectedChannel(pubKey: lightningNodeURI.pubKey, amount: amount, completion: completion)
                    }
                }
            }
        }
    }

    private func openConnectedChannel(pubKey: String, amount: Satoshi, completion: @escaping (Swift.Result<ChannelPoint, LndApiError>) -> Void) {
        api.openChannel(pubKey: pubKey, amount: amount) {
            completion($0)
        }
    }

    public func close(_ channel: Channel, completion: @escaping (Swift.Result<CloseStatusUpdate, LndApiError>) -> Void) {
        let force = channel.state != .active
        api.closeChannel(channelPoint: channel.channelPoint, force: force) { [channelListUpdater] in
            channelListUpdater.update()
            completion($0)
        }
    }

    public func node(for remotePubkey: String, completion: @escaping (LightningNode?) -> Void) {
        api.nodeInfo(pubKey: remotePubkey) { result in
            switch result {
            case .success(let nodeInfo):
                let connectedNode = nodeInfo.node
                completion(connectedNode)
            case .failure:
                completion(nil)
            }
        }
    }
}
