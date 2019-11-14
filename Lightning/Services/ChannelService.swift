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

public final class ChannelService: NSObject {
    private let api: LightningApi
    private let channelListUpdater: ChannelListUpdater

    public var open: MutableObservableArray<OpenChannel> {
        return channelListUpdater.open
    }

    public var pending: MutableObservableArray<PendingChannel> {
        return channelListUpdater.pending
    }
    
    public let all = MutableObservableArray<Channel>()

    public var maxLocalBalance: Satoshi {
        var maxLocalBalance: Satoshi = 0
        for channel in channelListUpdater.open.array where channel.localBalance > maxLocalBalance {
            maxLocalBalance = channel.localBalance
        }
        return maxLocalBalance
    }

    public var maxRemoteBalance: Satoshi {
        var maxRemoteBalance: Satoshi = 0
        for channel in channelListUpdater.open.array where channel.remoteBalance > maxRemoteBalance {
            maxRemoteBalance = channel.remoteBalance
        }
        return maxRemoteBalance
    }

    let staticChannelBackupper: StaticChannelBackupper

    init(api: LightningApi, channelListUpdater: ChannelListUpdater, staticChannelBackupper: StaticChannelBackupper) {
        self.api = api
        self.channelListUpdater = channelListUpdater
        self.staticChannelBackupper = staticChannelBackupper

        super.init()
        
        combineLatest(channelListUpdater.open, channelListUpdater.pending) { open, pending -> [Channel] in
            open.collection + pending.collection
        }
        .observeNext { [weak self] in
            self?.all.replace(with: $0)
        }
        .dispose(in: reactive.bag)
        
        api.exportAllChannelsBackup { [weak self] in
            self?.handleChannelBackup($0)
        }

        api.subscribeChannelBackups { [weak self] in
            self?.handleChannelBackup($0)
        }
    }

    private func handleChannelBackup(_ result: Result<ChannelBackup, LndApiError>) {
        staticChannelBackupper.data = result.map { $0.data }
    }

    public func open(lightningNodeURI: LightningNodeURI, csvDelay: Int?, amount: Satoshi, completion: @escaping ApiCompletion<ChannelPoint>) {
        api.peers { [weak self, api] result in
            if (try? result.get())?.contains(where: { $0.pubKey == lightningNodeURI.pubKey }) == true {
                self?.openConnectedChannel(pubKey: lightningNodeURI.pubKey, csvDelay: csvDelay, amount: amount, completion: completion)
            } else {
                api.connect(pubKey: lightningNodeURI.pubKey, host: lightningNodeURI.host) { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    } else {
                        self?.openConnectedChannel(pubKey: lightningNodeURI.pubKey, csvDelay: csvDelay, amount: amount, completion: completion)
                    }
                }
            }
        }
    }

    private func openConnectedChannel(pubKey: String, csvDelay: Int?, amount: Satoshi, completion: @escaping ApiCompletion<ChannelPoint>) {
        api.openChannel(pubKey: pubKey, csvDelay: csvDelay, amount: amount) { [channelListUpdater] in
            channelListUpdater.update()
            completion($0)
        }
    }

    public func close(_ channel: Channel, completion: @escaping ApiCompletion<CloseStatusUpdate>) {
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

    public func update() {
        channelListUpdater.update()
    }
}
