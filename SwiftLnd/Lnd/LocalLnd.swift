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

// `WalletId` is used as a parameter for local lnd wallets. It is used as the
// folder containing all lnd data, so we can run multiple wallets on the same
// device.

public enum LocalLnd {
    public private(set) static var isRunning = false

    public static func start(walletId: WalletId) {
        guard !isRunning else { return }
        DispatchQueue.once(token: "start_lnd") {
            guard let lndUrl = FileManager.default.walletDirectory(for: walletId) else { return }

            Logger.info("start lnd", customPrefix: "🏁")
            LocalLndConfiguration.standard.save(at: lndUrl)

            signal(SIGPIPE, SIG_IGN) // Avoid crash on socket close.

            DispatchQueue.global(qos: .default).async {
                LndmobileStart(lndUrl.path, EmptyStreamCallback())
                BackupDisabler.disableNeutrinoBackup(walletId: walletId, network: .testnet)
                isRunning = true
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
