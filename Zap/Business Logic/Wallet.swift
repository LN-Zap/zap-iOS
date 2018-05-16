//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

enum WalletState {
    case locked
    case noInternet
    case noWallet
    case connecting
    case syncing
    case ready
}

final class Wallet {
    let bestHeaderDate = Observable<Date?>(nil)
    let blockChainHeight = Observable<Int?>(nil)
    let blockHeight = Observable(0)
    let isSyncedToChain = Observable(false)
    let alias = Observable<String?>(nil)
    let walletState: Observable<WalletState>
    
    var isLocked = false {
        didSet {
            updateWalletState(result: nil)
        }
    }
    
    static var didCreateWallet: Bool = true
    //    {
    //        get {
    //            return false
    //            return UserDefaults.Keys.didCreateWallet.get(defaultValue: false)
    //        }
    //        set {
    //            UserDefaults.Keys.didCreateWallet.set(newValue)
    //        }
    //    }
    
    init(api: LightningProtocol) {
        if Wallet.didCreateWallet {
            walletState = Observable(.connecting)
        } else {
            walletState = Observable(.noWallet)
        }
        
        Scheduler.schedule(interval: 120, job: BlockChainHeightJob { [blockChainHeight] height in
            blockChainHeight.value = height
        })
        
        Scheduler.schedule(interval: 1, action: { [api, updateInfo] in
            api.info(callback: updateInfo)
        })
    }
    
    private func updateInfo(result: Result<Info>) {
        if let info = result.value {
            blockHeight.value = info.blockHeight
            isSyncedToChain.value = info.isSyncedToChain
            alias.value = info.alias
            bestHeaderDate.value = info.bestHeaderDate
        }
        
        updateWalletState(result: result)
    }
    
    private func updateWalletState(result: Result<Info>?) {
        if !Wallet.didCreateWallet {
            walletState.value = .noWallet
        } else if isLocked {
            walletState.value = .locked
        } else if let result = result {
            if let info = result.value {
                if !Wallet.didCreateWallet {
                    walletState.value = .noWallet
                } else if !info.isSyncedToChain {
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
}
