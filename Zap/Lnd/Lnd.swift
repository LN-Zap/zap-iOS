//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation
import Lndmobile

final class Lnd {
    struct Constants {
        static let minChannelSize: Satoshi = 20000
        static let maxChannelSize: Satoshi = 16777216
        static let maxPaymentAllowed: Satoshi = 4294967
    }
    
    static var lndPath: URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else { fatalError("lnd path not found") }
        return url
    }
    
    static func start() {
        LndConfiguration.standard.save(at: lndPath)

        guard ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] != "1" else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            LndmobileStart(Lnd.lndPath.path, EmptyLndCallback())
        }
    }
    
    static func stop() {
        LndmobileStopDaemon(nil, EmptyLndCallback())
    }
}

// TODO: Connecting to remote LND:
//private final class RemoteConnection: ConnectionStrategy {
//    let host = "lnd3.ddns.net:10011"
//
//    var cert: String? {
//        return RemoteLndConfiguration.cert
//    }
//
//    var macaroon: String? {
//        return RemoteLndConfiguration.macaroon
//    }
//
//    func startLnd() {
//        lightning = Lnrpc_LightningServiceClient(address: host, certificates: cert, host: nil)
//        lightning?.metadata.add(key: "macaroon", value: Lnd.instance.macaroon!)
//        walletUnlocker = Lnrpc_WalletUnlockerServiceClient(address: host, certificates: cert, host: nil)
//    }
//
//    func stopLnd() {}
//}
