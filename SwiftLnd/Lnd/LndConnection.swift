//
//  Zap
//
//  Created by Otto Suess on 22.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum LndConnection {
    case none
    #if !LOCALONLY
    case local
    #endif
    case remote(RemoteRPCConfiguration)
    
    public var api: LightningApiProtocol? {
        if Environment.useMockApi {
            return ApiMockTemplate.selected.instance
        }
        
        switch self {
        case .none:
            return nil
        #if !LOCALONLY
        case .local:
            if !LocalLnd.isRunning {
                LocalLnd.start() // TODO: don't start local Lnd in the getter. bad api!
            }
            return LightningApiStream()
        #endif
        case .remote(let configuration):
            return LightningApiRPC(configuration: configuration)
        }
    }
    
    public static var current: LndConnection {
        if let remoteConfiguration = RemoteRPCConfiguration.load() {
            return .remote(remoteConfiguration)
        }
        #if !LOCALONLY
        if WalletService.didCreateWallet {
            return .local
        }
        #endif
        
        return .none
    }
}
