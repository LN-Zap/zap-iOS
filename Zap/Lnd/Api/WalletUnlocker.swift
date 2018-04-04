//
//  Zap
//
//  Created by Otto Suess on 17.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LightningRpc

private let PASSWORD = "12345678"

final class WalletUnlocker {
    private var rpc: LightningRpc.WalletUnlocker? {
        if Lnd.instance.walletUnlocker == nil {
            print("WalletUnlocker not initialized")
        }
        return Lnd.instance.walletUnlocker
    }
    
    func generateSeed(passphrase: String? = nil, callback: @escaping (Result<[String]>) -> Void) {
        let request = GenSeedRequest()
        if let passphrase = passphrase {
            request.aezeedPassphrase = passphrase.data(using: .utf8)
        }
        
        rpc?.genSeed(with: request, handler: result(callback, map: {
            $0.cipherSeedMnemonicArray as? [String]
        }))
    }
    
    func initWallet(mnemonic: [String], callback: @escaping (Result<Void>) -> Void) {
        let request = InitWalletRequest()
        request.walletPassword = PASSWORD.data(using: .utf8)
        request.cipherSeedMnemonicArray = NSMutableArray(array: mnemonic)

        rpc?.initWallet(with: request, handler: result(callback, map: { _ in () }))
    }
    
    func unlockWallet(callback: @escaping (Result<Void>) -> Void) {
        let request = UnlockWalletRequest()
        request.walletPassword = PASSWORD.data(using: .utf8)
        
        rpc?.unlockWallet(with: request, handler: result(callback, map: { _ in () }))
    }
}
