//
//  ZapShared
//
//  Created by Otto Suess on 20.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile

public final class WalletApiStream: WalletApiProtocol {
    public init() {}
    
    public func generateSeed(passphrase: String? = nil, completion: @escaping (Result<[String]>) -> Void) {
        let data = try? LNDGenSeedRequest(passphrase: passphrase).serializedData()
        LndmobileGenSeed(data, StreamCallback<LNDGenSeedResponse, [String]>(completion) { $0.cipherSeedMnemonic })
    }
    
    public func initWallet(mnemonic: [String], password: String, completion: @escaping (Result<Success>) -> Void) {
        let data = try? LNDInitWalletRequest(password: password, mnemonic: mnemonic).serializedData()
        LndmobileInitWallet(data, StreamCallback<LNDInitWalletResponse, Success>(completion) { _ in Success() })
    }
    
    public func unlockWallet(password: String, completion: @escaping (Result<Success>) -> Void) {
        let data = try? LNDUnlockWalletRequest(password: password).serializedData()
        LndmobileUnlockWallet(data, StreamCallback<LNDUnlockWalletResponse, Success>(completion) { _ in Success() })
    }
}

#endif
