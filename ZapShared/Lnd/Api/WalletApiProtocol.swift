//
//  ZapShared
//
//  Created by Otto Suess on 20.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

protocol WalletApiProtocol {
    func generateSeed(passphrase: String?, callback: @escaping (Result<[String]>) -> Void)
    func initWallet(mnemonic: [String], password: String, callback: @escaping (Result<Void>) -> Void)
    func unlockWallet(password: String, callback: @escaping (Result<Void>) -> Void)
}
