//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

final class WalletService {
    private let password = "12345678" // TODO: save random pw in secure enclave
    
    private(set) var isUnlocked = false
    private let wallet: WalletProtocol
    
    init(wallet: WalletProtocol) {
        self.wallet = wallet
    }
    
    private(set) static var didCreateWallet: Bool {
        get {
            return UserDefaults.Keys.didCreateWallet.get(defaultValue: false)
        }
        set {
            UserDefaults.Keys.didCreateWallet.set(newValue)
        }
    }
    
    func generateSeed(callback: @escaping (Result<[String]>) -> Void) {
        wallet.generateSeed(passphrase: nil, callback: callback)
    }
    
    func initWallet(mnemonic: [String], callback: @escaping (Result<Void>) -> Void) {
        wallet.initWallet(mnemonic: mnemonic, password: password) {
            if $0.value != nil {
                WalletService.didCreateWallet = true
            }
            callback($0)
        }
    }
    
    func unlockWallet(callback: @escaping (Result<Void>) -> Void) {
        wallet.unlockWallet(password: password, callback: callback)
    }
}
