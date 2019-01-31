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
    public var info: Info?
    
    let isSyncedToChain = Observable(false)

    private var heightJobTimer: Timer?
    private var updateInfoTimer: Timer?
    
    init(api: LightningApiProtocol, persistence: Persistence, channelService: ChannelService, balanceService: BalanceService, historyService: HistoryService) {
        self.persistence = persistence
        self.channelService = channelService
        self.balanceService = balanceService
        self.historyService = historyService
        
        walletState = Observable(.connecting)
        
        heightJobTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            BlockchainHeight.get(for: self.network.value) { self.blockChainHeight.value = $0 }
        }
        heightJobTimer?.fire()
        
        updateInfoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            api.info { self?.updateInfo(result: $0) }
        }
        updateInfoTimer?.fire()
    }
    
    private func updateInfo(result: Result<Info, LndApiError>) {
        if let info = result.value {
            blockHeight.value = info.blockHeight
            isSyncedToChain.value = info.isSyncedToChain
            bestHeaderDate.value = info.bestHeaderDate
            network.value = info.network
            
            persistence.setConnectedNode(pubKey: info.pubKey)
            
            self.info = info
        }
        
        let newState = walletState(for: result)
        if walletState.value != newState {
            if newState != .connecting {
                channelService.update()
                balanceService.update()
                historyService.update()
            }
            
            walletState.value = newState
        }
    }
    
    private func walletState(for result: Result<Info, LndApiError>?) -> State {
        guard let result = result else { return .connecting }
        
        if let info = result.value {
            if !info.isSyncedToChain {
                return .syncing
            } else {
                return .running
            }
        }
        
        return .connecting
    }
    
    func stop() {
        heightJobTimer?.invalidate()
        updateInfoTimer?.invalidate()
    }
}
