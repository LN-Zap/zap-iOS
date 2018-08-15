//
//  ZapShared
//
//  Created by Otto Suess on 20.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !LOCALONLY

import Foundation
import Lndmobile

public final class WalletApiStream: WalletApiProtocol {
    public init() {}
    
    public func generateSeed(passphrase: String? = nil, callback: @escaping (Result<[String]>) -> Void) {
        let data = try? Lnrpc_GenSeedRequest(passphrase: passphrase).serializedData()
        LndmobileGenSeed(data, StreamCallback<Lnrpc_GenSeedResponse, [String]>(callback) { $0.cipherSeedMnemonic })
    }
    
    public func initWallet(mnemonic: [String], password: String, callback: @escaping (Result<Success>) -> Void) {
        let data = try? Lnrpc_InitWalletRequest(password: password, mnemonic: mnemonic).serializedData()
        LndmobileInitWallet(data, StreamCallback<Lnrpc_InitWalletResponse, Success>(callback) { _ in Success() })
    }
    
    public func unlockWallet(password: String, callback: @escaping (Result<Success>) -> Void) {
        let data = try? Lnrpc_UnlockWalletRequest(password: password).serializedData()
        LndmobileUnlockWallet(data, StreamCallback<Lnrpc_UnlockWalletResponse, Success>(callback) { _ in Success() })
    }
}

#endif
