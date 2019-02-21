//
//  SwiftLnd
//
//  Created by Otto Suess on 20.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import LndRpc

extension GRPCCall {
    static func setup(_ configuration: RemoteRPCConfiguration) {
        GRPCCall.resetHostSettings()
        
        let host = configuration.url.absoluteString
        if let certificate = configuration.certificate {
            try? GRPCCall.setTLSPEMRootCerts(certificate, forHost: host)
        }
    }
}
