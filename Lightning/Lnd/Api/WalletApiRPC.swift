//
//  Zap
//
//  Created by Otto Suess on 17.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

private extension Lnrpc_WalletUnlockerServiceClient {
    convenience init(configuration: RemoteRPCConfiguration) {
        if let certificate = configuration.certificate {
            self.init(address: configuration.url.absoluteString, certificates: certificate)
        } else {
            self.init(address: configuration.url.absoluteString)
        }
        try? metadata.add(key: "macaroon", value: configuration.macaroon.hexString())
    }
}

final class WalletApiRPC: WalletApiProtocol {
    private let rpc: Lnrpc_WalletUnlockerService
    
    init(configuration: RemoteRPCConfiguration) {
        rpc = Lnrpc_WalletUnlockerServiceClient(configuration: configuration)
    }
    
    func generateSeed(passphrase: String? = nil, callback: @escaping (Result<[String]>) -> Void) {
        let request = Lnrpc_GenSeedRequest(passphrase: passphrase)
        _ = try? rpc.genSeed(request, completion: result(callback, map: { $0.cipherSeedMnemonic }))
    }
    
    func initWallet(mnemonic: [String], password: String, callback: @escaping (Result<Success>) -> Void) {
        let request = Lnrpc_InitWalletRequest(password: password, mnemonic: mnemonic)
        _ = try? rpc.initWallet(request, completion: result(callback, map: { _ in Success() }))
    }
    
    func unlockWallet(password: String, callback: @escaping (Result<Success>) -> Void) {
        let request = Lnrpc_UnlockWalletRequest(password: password)
        _ = try? rpc.unlockWallet(request, completion: result(callback, map: { _ in Success() }))
    }
}
