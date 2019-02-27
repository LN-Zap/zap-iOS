//
//  SwiftLnd
//
//  Created by Otto Suess on 20.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import LndRpc

public class RpcApi {
    let macaroon: String
    let configuration: RPCCredentials

    public init(configuration: RPCCredentials) {
        self.configuration = configuration
        macaroon = configuration.macaroon.hexadecimalString

        GRPCCall.setup(configuration)
    }

    public func resetConnection() {
        GRPCCall.setup(configuration)
    }
}
