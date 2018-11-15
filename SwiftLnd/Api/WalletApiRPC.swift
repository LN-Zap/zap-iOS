//
//  Zap
//
//  Created by Otto Suess on 17.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

extension Lnrpc_WalletUnlockerServiceClient {
    convenience init(configuration: RemoteRPCConfiguration) {
        if let certificate = configuration.certificate {
            self.init(address: configuration.url.absoluteString, certificates: certificate)
        } else {
            self.init(address: configuration.url.absoluteString)
        }
        try? metadata.add(key: "macaroon", value: configuration.macaroon.hexadecimalString)
    }
}

public final class WalletApiRPC: WalletApiProtocol {
    private let rpc: Lnrpc_WalletUnlockerService
    
    public init(configuration: RemoteRPCConfiguration) {
        rpc = Lnrpc_WalletUnlockerServiceClient(configuration: configuration)
    }
    
    public func generateSeed(passphrase: String? = nil, completion: @escaping (Result<[String]>) -> Void) {
        let request = Lnrpc_GenSeedRequest(passphrase: passphrase)
        _ = try? rpc.genSeed(request, completion: result(completion, map: { $0.cipherSeedMnemonic }))
    }
    
    public func initWallet(mnemonic: [String], password: String, completion: @escaping (Result<Success>) -> Void) {
        let request = Lnrpc_InitWalletRequest(password: password, mnemonic: mnemonic)
        _ = try? rpc.initWallet(request, completion: result(completion, map: { _ in Success() }))
    }
    
    public func unlockWallet(password: String, completion: @escaping (Result<Success>) -> Void) {
        let request = Lnrpc_UnlockWalletRequest(password: password)
        _ = try? rpc.unlockWallet(request, completion: result(completion, map: { _ in Success() }))
    }
}
