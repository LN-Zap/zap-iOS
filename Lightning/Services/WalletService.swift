//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public final class WalletService {
    private let password = "12345678" // TODO: save random pw in secure enclave
    
    private(set) var isUnlocked = false
    private let wallet: WalletApiProtocol
    
    public init(wallet: WalletApiProtocol) {
        self.wallet = wallet
    }
    
    private(set) static var didCreateWallet: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didCreateWallet")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "didCreateWallet")
        }
    }
    
    public func generateSeed(callback: @escaping (Result<[String]>) -> Void) {
        wallet.generateSeed(passphrase: nil, callback: callback)
    }
    
    public func initWallet(mnemonic: [String], callback: @escaping (Result<Void>) -> Void) {
        wallet.initWallet(mnemonic: mnemonic, password: password) {
            if $0.value != nil {
                WalletService.didCreateWallet = true
            }
            callback($0)
        }
    }
    
    public func unlockWallet(callback: @escaping (Result<Void>) -> Void) {
        wallet.unlockWallet(password: password, callback: callback)
    }
}
