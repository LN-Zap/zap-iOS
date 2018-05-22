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
    
    var viewModel: ViewModel? {
        switch self {
        case .none:
            return nil
        case .local:
            Lnd.start()
            return ViewModel(api: LightningStream())
        case .remote(let remoteNodeConfiguration):
            let lndRPCServer = LndRpcServer(configuration: remoteNodeConfiguration)
            return ViewModel(api: LightningRPC(lnd: lndRPCServer))
        }
    }
    
    static var current: LndConnection {
        if let remoteConfiguration = RemoteNodeConfiguration.load() {
            return .remote(remoteConfiguration)
        } else if didCreateWallet {
            return .local
        } else {
            return .none
        }
    }
    
    static private var didCreateWallet: Bool {
        get {
            return UserDefaults.Keys.didCreateWallet.get(defaultValue: false)
        }
        set {
            UserDefaults.Keys.didCreateWallet.set(newValue)
        }
    }
}
