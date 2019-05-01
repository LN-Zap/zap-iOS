//
//  SwiftLnd
//
//  Created by 0 on 30.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public final class WalletApi {
    public enum Kind {
        case local
        case remote(RPCCredentials)
    }

    let connection: WalletUnlockerConnection

    public init(connection: Kind) {
        switch connection {
        case .local:
            #if !REMOTEONLY
            self.connection = StreamingWalletUnlockerConnection()
            #else
            fatalError("local connection not available")
            #endif
        case .remote(let configuration):
            self.connection = RPCWalletUnlockerConnection(configuration: configuration)
        }
    }

    public func generateSeed(passphrase: String?, completion: @escaping ApiCompletion<[String]>) {
        let request = Lnrpc_GenSeedRequest(passphrase: passphrase)
        connection.genSeed(request, completion: run(completion) { $0.cipherSeedMnemonic })
    }

    public func initWallet(mnemonic: [String], password: String, completion: @escaping ApiCompletion<Success>) {
        let request = Lnrpc_InitWalletRequest(password: password, mnemonic: mnemonic)
        connection.initWallet(request, completion: run(completion) { _ in Success() })
    }

    public func unlockWallet(password: String, completion: @escaping ApiCompletion<Success>) {
        let request = Lnrpc_UnlockWalletRequest(password: password)
        connection.unlockWallet(request, completion: run(completion) { _ in Success() })
    }
}
