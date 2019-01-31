//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import SQLite
import SwiftBTC
import SwiftLnd

public final class ChannelService {
    private let api: LightningApiProtocol
    private let persistence: Persistence
    
    let all: Signal<[Channel], NoError>
    public let open = Observable<[Channel]>([])
    public let pending = Observable<[Channel]>([])
    public let closed = Observable<[ChannelCloseSummary]>([])
    
    init(api: LightningApiProtocol, persistence: Persistence) {
        self.api = api
        self.persistence = persistence
        
        all = combineLatest(open, pending) {
            $0 as [Channel] + $1 as [Channel]
        }
    }

    public func update() {
        api.channels { [open, channelsUpdated] result in
            open.value = result.value ?? []
            channelsUpdated(open.value)
        }
        
        api.pendingChannels { [pending, channelsUpdated] result in
            pending.value = result.value ?? []
            channelsUpdated(pending.value)
        }
        
        api.closedChannels { [closed, closedChannelsUpdated] result in
            closed.value = result.value ?? []
            closedChannelsUpdated(closed.value)
        }
    }
    
    public func open(lightningNodeURI: LightningNodeURI, amount: Satoshi, completion: @escaping (SwiftLnd.Result<ChannelPoint, LndApiError>) -> Void) {
        api.peers { [weak self, api] peers in
            if peers.value?.contains(where: { $0.pubKey == lightningNodeURI.pubKey }) == true {
                self?.openConnectedChannel(pubKey: lightningNodeURI.pubKey, amount: amount, completion: completion)
            } else {
                api.connect(pubKey: lightningNodeURI.pubKey, host: lightningNodeURI.host) { result in
                    if let error = result.error {
                        completion(.failure(LndApiError.localizedError(error.localizedDescription)))
                    } else {
                        self?.openConnectedChannel(pubKey: lightningNodeURI.pubKey, amount: amount, completion: completion)
                    }
                }
            }
        }
    }
    
    private func openConnectedChannel(pubKey: String, amount: Satoshi, completion: @escaping (SwiftLnd.Result<ChannelPoint, LndApiError>) -> Void) {
        api.openChannel(pubKey: pubKey, amount: amount) { [weak self] in
            self?.update()
            completion($0)
        }
    }
    
    public func close(_ channel: Channel, completion: @escaping (SwiftLnd.Result<CloseStatusUpdate, LndApiError>) -> Void) {
        let force = channel.state != .active
        api.closeChannel(channelPoint: channel.channelPoint, force: force) { [weak self] in
            self?.update()
            completion($0)
        }
    }
    
    public func node(for remotePubkey: String, completion: @escaping (ConnectedNode?) -> Void) {
        api.nodeInfo(pubKey: remotePubkey) { [persistence] result in
            if let lightningNode = result.value {
                let connectedNode = ConnectedNode(lightningNode: lightningNode.node)
                try? connectedNode.insert(database: persistence.connection())
                completion(connectedNode)
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - Persistence
extension ChannelService {
    private func channelsUpdated(_ channels: [Channel]) {
        do {
            for channel in channels {
                guard let openEvent = ChannelEvent(channel: channel) else { continue }
                try openEvent.insert(database: persistence.connection())
                try updateNodeIfNeeded(openEvent.node)
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
    
    private func closedChannelsUpdated(_ channelCloseSummaries: [ChannelCloseSummary]) {
        do {
            let database = try persistence.connection()
            
            let closingTxIds = channelCloseSummaries.map { $0.closingTxHash }
            try markTxIdsAsChannelRelated(txIds: closingTxIds)
            
            let openingTxIds = channelCloseSummaries.map { $0.channelPoint.fundingTxid }
            try markTxIdsAsChannelRelated(txIds: openingTxIds)
            
            for channelCloseSummary in channelCloseSummaries {
                let closeEvent = ChannelEvent(closing: channelCloseSummary)
                try closeEvent.insert(database: database)
                try updateNodeIfNeeded(closeEvent.node)
                
                if channelCloseSummary.openHeight > 0 { // chanID is 0 for channels opened by remote nodes
                    let openEvent = ChannelEvent(opening: channelCloseSummary)
                    try openEvent.insert(database: database)
                    try updateNodeIfNeeded(openEvent.node)
                }
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
    
    private func markTxIdsAsChannelRelated(txIds: [String]) throws {
        let query = TransactionEvent.table
            .filter(TransactionEvent.Column.type == TransactionEvent.TransactionEventType.unknown.rawValue)
            .filter(txIds.contains(TransactionEvent.Column.txHash))
        try persistence.connection().run(query.update(TransactionEvent.Column.type <- TransactionEvent.TransactionEventType.userInitiated.rawValue))
    }
    
    private func updateNodeIfNeeded(_ node: ConnectedNode) throws {
        self.node(for: node.pubKey) { _ in }
    }
}
