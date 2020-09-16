//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile
import Logger
import SwiftBTC

public enum LocalLnd {
    public private(set) static var isRunning = false

    public static func start(network: Network) {
        guard !isRunning else { return }
        DispatchQueue.once(token: "start_lnd") {
            guard let lndUrl = FileManager.default.walletDirectory else { return }

            var configuration = LocalLndConfiguration()
            configuration.network = network
            configuration.save(at: lndUrl)

            Logger.info("start lnd", customPrefix: "🏁")

            signal(SIGPIPE, SIG_IGN) // Avoid crash on socket close.

            NetworkConnection.startConnectivityCheck { isConnected in
                if isConnected {
                    DispatchQueue.global(qos: .default).async {
                        LndmobileStart("--lnddir=\(lndUrl.path)", EmptyStreamCallback())
                        BackupDisabler.disableNeutrinoBackup(network: network)
                        isRunning = true
                    }
                } else {
                    // TODO: Display new error vc
                }
            }
        }
    }
}

private extension DispatchQueue {
    private static var onceTracker = [String]()

    static func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        guard !onceTracker.contains(token) else { return }
        onceTracker.append(token)
        block()
    }
}

#endif
