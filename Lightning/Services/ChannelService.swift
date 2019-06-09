//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import SwiftBTC
import SwiftLnd

public final class ChannelService {
    private let api: LightningApi
    private let channelListUpdater: ChannelListUpdater

    public var open: MutableObservableArray<Channel> {
        return channelListUpdater.open
    }

    public var pending: MutableObservableArray<Channel> {
        return channelListUpdater.pending
    }

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

        api.exportAllChannelsBackup { [weak self] in
            self?.handleChannelBackup($0)
        }

        api.subscribeChannelBackups { [weak self] in
            self?.handleChannelBackup($0)
        }
    }

    private func handleChannelBackup(_ result: Result<ChannelBackup, LndApiError>) {
        switch result {
        case .success(let backup):
            staticChannelBackupper.data = backup.data
        case .failure(let error):
            Logger.error(error)
        }
    }

    public func open(lightningNodeURI: LightningNodeURI, amount: Satoshi, confirmationTarget: Int, completion: @escaping ApiCompletion<ChannelPoint>) {
        api.peers { [weak self, api] result in
            if (try? result.get())?.contains(where: { $0.pubKey == lightningNodeURI.pubKey }) == true {
                self?.openConnectedChannel(pubKey: lightningNodeURI.pubKey, amount: amount, confirmationTarget: confirmationTarget, completion: completion)
            } else {
                api.connect(pubKey: lightningNodeURI.pubKey, host: lightningNodeURI.host) { result in
                    if case .failure(let error) = result {
                        completion(.failure(LndApiError.localizedError(error.localizedDescription)))
                    } else {
                        self?.openConnectedChannel(pubKey: lightningNodeURI.pubKey, amount: amount, confirmationTarget: confirmationTarget, completion: completion)
                    }
                }
            }
        }
    }

    private func openConnectedChannel(pubKey: String, amount: Satoshi, confirmationTarget: Int, completion: @escaping ApiCompletion<ChannelPoint>) {
        api.openChannel(pubKey: pubKey, amount: amount, confirmationTarget: confirmationTarget) { [channelListUpdater] in
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

    func update() {
        channelListUpdater.update()
    }
}
