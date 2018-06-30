//
//  Zap
//
//  Created by Otto Suess on 22.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum LndConnection {
    case none
    case local
    case remote(RemoteRPCConfiguration)
    
    var api: LightningApiProtocol? {
        switch self {
        case .none:
            return nil
        case .local:
            if !LocalLnd.isRunning {
                LocalLnd.start() // TODO: don't start local Lnd in the getter. bad api!
            }
            return LightningApiStream()
        case .remote(let configuration):
            return LightningApiRPC(configuration: configuration)
        }
    }
    
    public static var current: LndConnection {
        if let remoteConfiguration = RemoteRPCConfiguration.load() {
            return .remote(remoteConfiguration)
        } else if WalletService.didCreateWallet {
            return .local
        } else {
            return .none
        }
    }
}
