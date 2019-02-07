//
//  Zap
//
//  Created by Otto Suess on 17.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc

public final class WalletApiRPC: WalletApiProtocol {
    private let lnd: LNDWalletUnlocker
    private let macaroon: String

    public init(configuration: RemoteRPCConfiguration) {
        let host = configuration.url.absoluteString
        lnd = LNDWalletUnlocker(host: host)
        if let certificate = configuration.certificate {
            try? GRPCCall.setTLSPEMRootCerts(certificate, forHost: host)
        }
        macaroon = configuration.macaroon.hexadecimalString
    }
    
    public func generateSeed(passphrase: String? = nil, completion: @escaping (Result<[String], LndApiError>) -> Void) {
        let request = LNDGenSeedRequest(passphrase: passphrase)
        lnd.rpcToGenSeed(with: request, handler: createHandler(completion, transform: WalletApiTransformation.generateSeed)).runWithMacaroon(macaroon)
    }
    
    public func initWallet(mnemonic: [String], password: String, completion: @escaping (Result<Success, LndApiError>) -> Void) {
        let request = LNDInitWalletRequest(password: password, mnemonic: mnemonic)
        lnd.rpcToInitWallet(with: request, handler: createHandler(completion, transform: WalletApiTransformation.initWallet)).runWithMacaroon(macaroon)
    }
    
    public func unlockWallet(password: String, completion: @escaping (Result<Success, LndApiError>) -> Void) {
        let request = LNDUnlockWalletRequest(password: password)
        lnd.rpcToUnlockWallet(with: request, handler: createHandler(completion, transform: WalletApiTransformation.unlockWallet)).runWithMacaroon(macaroon)
    }
}
