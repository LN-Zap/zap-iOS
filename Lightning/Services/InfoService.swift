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
    
    public let balanceService: BalanceService
    public let channelService: ChannelService
    public let historyService: HistoryService
    
    public let bestHeaderDate = Observable<Date?>(nil)
    public let blockChainHeight = Observable<Int?>(nil)
    public let blockHeight = Observable(0)
    public let walletState: Observable<InfoService.State>
    public let network = Observable<Network>(.testnet)
    public var info = Observable<Info?>(nil)
    
    let isSyncedToChain = Observable(false)

    private var heightJobTimer: Timer?
    private var updateInfoTimer: Timer?
    
    init(api: LightningApiProtocol, channelService: ChannelService, balanceService: BalanceService, historyService: HistoryService) {
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
            if blockHeight.value != info.blockHeight {
                blockHeight.value = info.blockHeight
            }
            if isSyncedToChain.value != info.isSyncedToChain {
                isSyncedToChain.value = info.isSyncedToChain
            }
            if bestHeaderDate.value != info.bestHeaderDate {
                bestHeaderDate.value = info.bestHeaderDate
            }
            if network.value != info.network {
                network.value = info.network
            }

            self.info.value = info
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
