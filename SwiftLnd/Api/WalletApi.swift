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

    public func generateSeed(completion: @escaping ApiCompletion<[String]>) {
        let request = Lnrpc_GenSeedRequest()
        connection.genSeed(request, completion: map(completion) { $0.cipherSeedMnemonic })
    }

    public func initWallet(mnemonic: [String], password: String, channelBackup: ChannelBackup?, recover: Bool, completion: @escaping ApiCompletion<Success>) {
        // 2500 is the default value for address lookahead from lncli. This
        // might lead to a lot of false positive block downloads. so we use 100
        // instead. It seems unlikely that a mobile app user generates more
        // than 100 addresses without using them.
        // https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md#starting-on-chain-recovery
        let recoverWindow = recover ? 100 : 0
        let request = Lnrpc_InitWalletRequest(password: password, mnemonic: mnemonic, channelBackup: channelBackup, recoverWindow: recoverWindow)
        connection.initWallet(request, completion: map(completion) { _ in Success() })
    }

    public func unlockWallet(password: String, completion: @escaping ApiCompletion<Success>) {
        let request = Lnrpc_UnlockWalletRequest(password: password)
        connection.unlockWallet(request, completion: map(completion) { _ in Success() })
    }
}
