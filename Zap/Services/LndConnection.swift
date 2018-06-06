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
    case remote(RemoteNodeConfiguration)
    
    var viewModel: LightningService? {
        switch self {
        case .none:
            return nil
        case .local:
            Lnd.start()
            return LightningService(api: LightningStream())
        case .remote(let remoteNodeConfiguration):
            let lndRPCServer = LndRpcServer(configuration: remoteNodeConfiguration)
            return LightningService(api: LightningRPC(lnd: lndRPCServer))
        }
    }
    
    static var current: LndConnection {
        if let remoteConfiguration = RemoteNodeConfiguration.load() {
            return .remote(remoteConfiguration)
        } else if WalletService.didCreateWallet {
            return .local
        } else {
            return .none
        }
    }
}
