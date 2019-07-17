//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftLnd

public final class WalletService {
    public private(set) static var isLocalWalletUnlocked = false
    private let wallet: WalletApi
    public let connection: LightningConnection

    public init(connection: LightningConnection) {
        self.connection = connection

        switch connection {
        case .local:
        #if !REMOTEONLY
            self.wallet = WalletApi(connection: .local)
        #else
            fatalError(".local not supported")
        #endif
        case .remote(let configuration):
            self.wallet = WalletApi(connection: .remote(configuration))
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

    public func generateSeed(completion: @escaping ApiCompletion<[String]>) {
        wallet.generateSeed(passphrase: nil) {
            completion($0)
        }
    }

    public func initWallet(password: String, mnemonic: [String], completion: @escaping ApiCompletion<Success>) {
        wallet.initWallet(mnemonic: mnemonic, password: password) {
            if case .success = $0 {
                WalletService.didCreateWallet = true
                WalletService.isLocalWalletUnlocked = true
            }
            completion($0)
        }
    }

    public func unlockWallet(password: String, completion: @escaping ApiCompletion<Success>) {
        wallet.unlockWallet(password: password) {
            if case .success = $0 {
                WalletService.isLocalWalletUnlocked = true
            }
            completion($0)
        }
    }
}
