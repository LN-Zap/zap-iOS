//
//  ZapShared
//
//  Created by Otto Suess on 20.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public protocol WalletApiProtocol {
    func generateSeed(passphrase: String?, completion: @escaping (Result<[String]>) -> Void)
    func initWallet(mnemonic: [String], password: String, completion: @escaping (Result<Success>) -> Void)
    func unlockWallet(password: String, completion: @escaping (Result<Success>) -> Void)
}
