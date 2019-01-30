//
//  ZapShared
//
//  Created by Otto Suess on 20.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile
import LndRpc

public final class WalletApiStream: WalletApiProtocol {
    public init() {}
    
    public func generateSeed(passphrase: String? = nil, completion: @escaping (Result<[String]>) -> Void) {
        let data = LNDGenSeedRequest(passphrase: passphrase).data()
        LndmobileGenSeed(data, StreamCallback<LNDGenSeedResponse, [String]>(completion) { $0.cipherSeedMnemonicArray.compactMap { $0 as? String } })
    }
    
    public func initWallet(mnemonic: [String], password: String, completion: @escaping (Result<Success>) -> Void) {
        let data = LNDInitWalletRequest(password: password, mnemonic: mnemonic).data()
        LndmobileInitWallet(data, StreamCallback<LNDInitWalletResponse, Success>(completion) { _ in Success() })
    }
    
    public func unlockWallet(password: String, completion: @escaping (Result<Success>) -> Void) {
        let data = LNDUnlockWalletRequest(password: password).data()
        LndmobileUnlockWallet(data, StreamCallback<LNDUnlockWalletResponse, Success>(completion) { _ in Success() })
    }
}

#endif
