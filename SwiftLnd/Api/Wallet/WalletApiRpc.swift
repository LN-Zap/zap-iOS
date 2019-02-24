//
//  Zap
//
//  Created by Otto Suess on 17.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc

public final class WalletApiRpc: RpcApi, WalletApiProtocol {
    private let lnd: LNDWalletUnlocker

    override public init(configuration: RemoteRPCConfiguration) {
        lnd = LNDWalletUnlocker(host: configuration.url.absoluteString)
        super.init(configuration: configuration)
    }

    public func generateSeed(passphrase: String? = nil, completion: @escaping Handler<[String]>) {
        let request = LNDGenSeedRequest(passphrase: passphrase)
        lnd.genSeed(with: request, handler: createHandler(completion, transform: WalletApiTransformation.generateSeed))
    }

    public func initWallet(mnemonic: [String], password: String, completion: @escaping Handler<Success>) {
        let request = LNDInitWalletRequest(password: password, mnemonic: mnemonic)
        lnd.initWallet(with: request, handler: createHandler(completion, transform: WalletApiTransformation.initWallet))
    }

    public func unlockWallet(password: String, completion: @escaping Handler<Success>) {
        let request = LNDUnlockWalletRequest(password: password)
        lnd.unlockWallet(with: request, handler: createHandler(completion, transform: WalletApiTransformation.unlockWallet))
    }
}
