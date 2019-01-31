//
//  Zap
//
//  Created by Otto Suess on 17.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

//extension LNDWalletUnlockerServiceClient {
//    convenience init(configuration: RemoteRPCConfiguration) {
//        if let certificate = configuration.certificate {
//            self.init(address: configuration.url.absoluteString, certificates: certificate)
//        } else {
//            self.init(address: configuration.url.absoluteString)
//        }
//        try? metadata.add(key: "macaroon", value: configuration.macaroon.hexadecimalString)
//    }
//}
//
public final class WalletApiRPC: WalletApiProtocol {
//    private let rpc: LNDWalletUnlockerService
    
    public init(configuration: RemoteRPCConfiguration) {
//        rpc = LNDWalletUnlockerServiceClient(configuration: configuration)
    }
    
    public func generateSeed(passphrase: String? = nil, completion: @escaping (Result<[String], LndApiError>) -> Void) {
//        let request = LNDGenSeedRequest(passphrase: passphrase)
//        _ = try? rpc.genSeed(request, completion: result(completion, map: { $0.cipherSeedMnemonic }))
    }
    
    public func initWallet(mnemonic: [String], password: String, completion: @escaping (Result<Success, LndApiError>) -> Void) {
//        let request = LNDInitWalletRequest(password: password, mnemonic: mnemonic)
//        _ = try? rpc.initWallet(request, completion: result(completion, map: { _ in Success() }))
    }
    
    public func unlockWallet(password: String, completion: @escaping (Result<Success, LndApiError>) -> Void) {
//        let request = LNDUnlockWalletRequest(password: password)
//        _ = try? rpc.unlockWallet(request, completion: result(completion, map: { _ in Success() }))
    }
}
