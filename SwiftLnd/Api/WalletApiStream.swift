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
    
    public func generateSeed(passphrase: String? = nil, completion: @escaping (Result<[String]>) -> Void) {
        let data = try? Lnrpc_GenSeedRequest(passphrase: passphrase).serializedData()
        LndmobileGenSeed(data, StreamCallback<Lnrpc_GenSeedResponse, [String]>(completion) { $0.cipherSeedMnemonic })
    }
    
    public func initWallet(mnemonic: [String], password: String, completion: @escaping (Result<Success>) -> Void) {
        let data = try? Lnrpc_InitWalletRequest(password: password, mnemonic: mnemonic).serializedData()
        LndmobileInitWallet(data, StreamCallback<Lnrpc_InitWalletResponse, Success>(completion) { _ in Success() })
    }
    
    public func unlockWallet(password: String, completion: @escaping (Result<Success>) -> Void) {
        let data = try? Lnrpc_UnlockWalletRequest(password: password).serializedData()
        LndmobileUnlockWallet(data, StreamCallback<Lnrpc_UnlockWalletResponse, Success>(completion) { _ in Success() })
    }
}

#endif
