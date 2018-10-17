//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftBTC
import SwiftLnd

public final class InfoService {
    public enum State {
        case noInternet
        case connecting
        case syncing
        case running
    }
    
    private let persistence: Persistence
    public let balanceService: BalanceService
    public let channelService: ChannelService
    public let historyService: HistoryService
    
    public let bestHeaderDate = Observable<Date?>(nil)
    public let blockChainHeight = Observable<Int?>(nil)
    public let blockHeight = Observable(0)
    public let walletState: Observable<InfoService.State>
    public let network = Observable<Network>(.testnet)
    
    let isSyncedToChain = Observable(false)

    private let heightJobTimer: Timer?
    private var updateInfoTimer: Timer?
    
    init(api: LightningApiProtocol, persistence: Persistence, channelService: ChannelService, balanceService: BalanceService, historyService: HistoryService) {
        self.persistence = persistence
        self.channelService = channelService
        self.balanceService = balanceService
        self.historyService = historyService
        
        walletState = Observable(.connecting)
        
        heightJobTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [blockChainHeight, network] _ in
            BlockchainHeight.get(for: network.value) { blockChainHeight.value = $0 }
        }
        heightJobTimer?.fire()
        
        updateInfoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [api, updateInfo] _ in
            api.info(completion: updateInfo)
        }
        updateInfoTimer?.fire()
    }
    
    private func updateInfo(result: Result<Info>) {
        if let info = result.value {
            blockHeight.value = info.blockHeight
            isSyncedToChain.value = info.isSyncedToChain
            bestHeaderDate.value = info.bestHeaderDate
            network.value = info.network
            
            persistence.setConnectedNode(pubKey: info.pubKey)
        }
        
        let newState = walletState(for: result)
        if walletState.value != newState {
            if newState != .connecting && newState != .noInternet {
                channelService.update()
                balanceService.update()
                historyService.update()
            }
            
            walletState.value = newState
        }
    }
    
    private func walletState(for result: Result<Info>?) -> State {
        guard let result = result else { return .connecting }
        
        if let info = result.value {
            if !info.isSyncedToChain {
                return .syncing
            } else {
                return .running
            }
        } else if let error = result.error as? LndApiError,
            error == LndApiError.noInternet {
            return .noInternet
        }
        
        return .connecting
    }
    
    func stop() {
        heightJobTimer?.invalidate()
        updateInfoTimer?.invalidate()
    }
}
