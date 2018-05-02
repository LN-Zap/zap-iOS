//
//  Zap
//
//  Created by Otto Suess on 17.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

private let PASSWORD = "12345678"

final class WalletUnlocker {
    private var rpc: Lnrpc_WalletUnlockerService? {
        if Lnd.instance.walletUnlocker == nil {
            print("WalletUnlocker not initialized")
        }
        return Lnd.instance.walletUnlocker
    }
    
    func generateSeed(passphrase: String? = nil, callback: @escaping (Result<[String]>) -> Void) {
        var request = Lnrpc_GenSeedRequest()
        if let passphrase = passphrase?.data(using: .utf8) {
            request.aezeedPassphrase = passphrase
        }
        
        _ = try? rpc?.genSeed(request, completion: result(callback, map: { $0.cipherSeedMnemonic }))
    }
    
    func initWallet(mnemonic: [String], callback: @escaping (Result<Void>) -> Void) {
        var request = Lnrpc_InitWalletRequest()
        if let passwordData = PASSWORD.data(using: .utf8) {
            request.walletPassword = passwordData
        }
        request.cipherSeedMnemonic = mnemonic

        _ = try? rpc?.initWallet(request, completion: result(callback, map: { _ in () }))
    }
    
    func unlockWallet(callback: @escaping (Result<Void>) -> Void) {
        var request = Lnrpc_UnlockWalletRequest()
        if let passwordData = PASSWORD.data(using: .utf8) {
            request.walletPassword = passwordData
        }

        _ = try? rpc?.unlockWallet(request, completion: result(callback, map: { _ in () }))
    }
}
