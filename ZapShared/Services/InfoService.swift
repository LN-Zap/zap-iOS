//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class InfoService {
    enum State {
        case locked
        case noInternet
        case connecting
        case syncing
        case ready
    }
    
    let bestHeaderDate = Observable<Date?>(nil)
    let blockChainHeight = Observable<Int?>(nil)
    let blockHeight = Observable(0)
    let isSyncedToChain = Observable(false)
    let alias = Observable<String?>(nil)
    let walletState: Observable<InfoService.State>
    let network = Observable<Network>(.testnet)
    
    private let heightJobTimer: Timer?
    private var updateInfoTimer: Timer?
    
    var isLocked = false {
        didSet {
            updateWalletState(result: nil)
        }
    }
    
    init(api: LightningProtocol) {
        walletState = Observable(.connecting)
        
        heightJobTimer = Scheduler.schedule(interval: 120, job: BlockChainHeightJob { [blockChainHeight] height in
            blockChainHeight.value = height
        })
        
        updateInfoTimer = Scheduler.schedule(interval: 1, action: { [api, updateInfo] in
            api.info(callback: updateInfo)
        })
    }
    
    private func updateInfo(result: Result<Info>) {
        if let info = result.value {
            blockHeight.value = info.blockHeight
            isSyncedToChain.value = info.isSyncedToChain
            alias.value = info.alias
            bestHeaderDate.value = info.bestHeaderDate
            network.value = info.network
        }
        
        updateWalletState(result: result)
    }
    
    private func updateWalletState(result: Result<Info>?) {
        if isLocked {
            walletState.value = .locked
        } else if let result = result {
            if let info = result.value {
                if !info.isSyncedToChain {
                    walletState.value = .syncing
                } else {
                    walletState.value = .ready
                }
            } else if let error = result.error as? LndError,
                error == LndError.noInternet {
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
