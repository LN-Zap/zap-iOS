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
    public let balanceService: BalanceService
    public let channelService: ChannelService
    public let historyService: HistoryService
    
    public let bestHeaderDate = Observable<Date?>(nil)
    public let blockChainHeight = Observable<Int?>(nil)
    public let blockHeight = Observable<Int?>(nil)
    public let network = Observable<Network?>(nil)
    public var info = Observable<Info?>(nil)
    
    private var heightJobTimer: Timer?
    private var updateInfoTimer: Timer?
    
    init(api: LightningApiProtocol, channelService: ChannelService, balanceService: BalanceService, historyService: HistoryService) {
        self.channelService = channelService
        self.balanceService = balanceService
        self.historyService = historyService
        
        heightJobTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            guard let network = self?.network.value else { return }
            BlockchainHeight.get(for: network) { self?.blockChainHeight.value = $0 }
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
            if bestHeaderDate.value != info.bestHeaderDate {
                bestHeaderDate.value = info.bestHeaderDate
            }
            if network.value != info.network {
                network.value = info.network
            }
        }
        
        let newIsSyncedToChain = result.value?.isSyncedToChain
        if info.value?.isSyncedToChain != newIsSyncedToChain && newIsSyncedToChain != nil {
            channelService.update()
            balanceService.update()
            historyService.update()
        }
        
        self.info.value = result.value
    }
    
    func stop() {
        heightJobTimer?.invalidate()
        updateInfoTimer?.invalidate()
    }
}
