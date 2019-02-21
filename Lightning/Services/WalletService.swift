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
    public let connection: LightningConnection
    
    public init(connection: LightningConnection) {
        self.connection = connection
        
        switch connection {
        case .local:
        #if !REMOTEONLY
            self.wallet = WalletApiStream()
        #else
            fatalError(".local not supported")
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
    
    public func generateSeed(completion: @escaping (Result<[String], LndApiError>) -> Void) {
        wallet.generateSeed(passphrase: nil) {
            completion($0)
        }
    }
    
    public func initWallet(mnemonic: [String], completion: @escaping (Result<Success, LndApiError>) -> Void) {
        wallet.initWallet(mnemonic: mnemonic, password: password) {
            if $0.value != nil {
                WalletService.didCreateWallet = true
            }
            completion($0)
        }
    }
    
    public func unlockWallet(completion: @escaping (Result<Success, LndApiError>) -> Void) {
        wallet.unlockWallet(password: password, completion: completion)
    }
}
