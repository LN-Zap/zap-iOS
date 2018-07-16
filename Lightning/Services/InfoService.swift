//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

public final class InfoService {
    public enum State {
        case noInternet
        case connecting
        case syncing
        case running
    }
    
    public let bestHeaderDate = Observable<Date?>(nil)
    public let blockChainHeight = Observable<Int?>(nil)
    public let blockHeight = Observable(0)
    public let walletState: Observable<InfoService.State>
    public let network = Observable<Network>(.testnet)
    
    let isSyncedToChain = Observable(false)

    private let heightJobTimer: Timer?
    private var updateInfoTimer: Timer?
    
    init(api: LightningApiProtocol) {
        walletState = Observable(.connecting)
        
        heightJobTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [blockChainHeight, network] _ in
            BlockchainHeight.get(for: network.value) { blockChainHeight.value = $0 }
        }
        heightJobTimer?.fire()
        
        updateInfoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [api, updateInfo] _ in
            api.info(callback: updateInfo)
        }
        updateInfoTimer?.fire()
    }
    
    private func updateInfo(result: Result<Info>) {
        if let info = result.value {
            blockHeight.value = info.blockHeight
            isSyncedToChain.value = info.isSyncedToChain
            bestHeaderDate.value = info.bestHeaderDate
            network.value = info.network
        }
        
        updateWalletState(result: result)
    }
    
    private func updateWalletState(result: Result<Info>?) {
        if let result = result {
            if let info = result.value {
                if !info.isSyncedToChain {
                    walletState.value = .syncing
                } else {
                    walletState.value = .running
                }
            } else if let error = result.error as? LndApiError,
                error == LndApiError.noInternet {
                walletState.value = .noInternet
            } else {
                walletState.value = .connecting
            }
        } else {
            walletState.value = .connecting
        }
    }
    
    func stop() {
        heightJobTimer?.invalidate()
        updateInfoTimer?.invalidate()
    }
}
