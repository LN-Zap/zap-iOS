//
//  SwiftLnd
//
//  Created by Otto Suess on 20.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftGRPC

extension ServiceClientBase {
    convenience init(configuration: RPCCredentials) {
        if let certificate = configuration.certificate {
            let arguments: [SwiftGRPC.Channel.Argument] = [
//                .keepAliveTime(10)
            ]

            self.init(address: configuration.host.absoluteString, certificates: certificate, arguments: arguments)
        } else {
            self.init(address: configuration.host.absoluteString)
        }

        metadata = try! Metadata([ // swiftlint:disable:this force_try
            "macaroon": configuration.macaroon.hexadecimalString
        ])

        timeout = Double(60 * 60 * 24 * 365) // otherwise streaming calls stop working after 10 minutes

//        Currently there seems to be a bug in Go Server Rpc that breaks the
//        ConnectivityObserver.
//
//        channel.addConnectivityObserver { [weak self] connectivityState in
//            Logger.info("Updated connectivityState: \(connectivityState)")
//
//            switch connectivityState {
//            case .transientFailure, .shutdown:
//                self?.channel.shutdown()
//            default:
//                break
//            }
//        }
    }
}
