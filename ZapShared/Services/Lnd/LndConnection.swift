//
//  Zap
//
//  Created by Otto Suess on 22.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum LndConnection {
    case none
    case local
    case remote(RemoteRPCConfiguration)
    
    var api: LightningProtocol? {
        switch self {
        case .none:
            return nil
        case .local:
            Lnd.start() // start local Lnd
            return LightningStream()
        case .remote(let configuration):
            return LightningRPC(configuration: configuration)
        }
    }
    
    static var current: LndConnection {
        if let remoteConfiguration = RemoteRPCConfiguration.load() {
            return .remote(remoteConfiguration)
        } else if WalletService.didCreateWallet {
            return .local
        } else {
            return .none
        }
    }
}
