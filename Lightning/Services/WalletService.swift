//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftLnd

public final class WalletService {
    private let password = "12345678" // TODO: save random pw in secure enclave
    
    private(set) var isUnlocked = false
    private let wallet: WalletApiProtocol
    
    public init(connection: LightningConnection) {
        switch connection {
        #if !LOCALONLY
        case .local:
            self.wallet = WalletApiStream()
        case .none:
            self.wallet = WalletApiStream()
        #else
        case .none:
            fatalError("can't create wallet service.")
        #endif
        case .remote(let configuration):
            self.wallet = WalletApiRPC(configuration: configuration)
        }
    }
    
    private(set) static var didCreateWallet: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didCreateWallet")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "didCreateWallet")
        }
    }
    
    public func generateSeed(completion: @escaping (Result<[String]>) -> Void) {
        wallet.generateSeed(passphrase: nil, completion: completion)
    }
    
    public func initWallet(mnemonic: [String], completion: @escaping (Result<Success>) -> Void) {
        wallet.initWallet(mnemonic: mnemonic, password: password) {
            if $0.value != nil {
                WalletService.didCreateWallet = true
            }
            completion($0)
        }
    }
    
    public func unlockWallet(completion: @escaping (Result<Success>) -> Void) {
        wallet.unlockWallet(password: password, completion: completion)
    }
}
