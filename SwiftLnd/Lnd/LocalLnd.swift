//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile

// `WalletId` is used as a parameter for local lnd wallets. It is used as the
// folder containing all lnd data, so we can run multiple wallets on the same
// device.

public enum LocalLnd {
    public private(set) static var isRunning = false

    public static func start(walletId: WalletId) {
        guard let lndUrl = FileManager.default.walletDirectory(for: walletId) else { return }
        isRunning = true
        LocalLndConfiguration.standard.save(at: lndUrl)
        LndmobileStart(lndUrl.path, EmptyStreamCallback())
    }

    public static func stop() {
        isRunning = false
        LndmobileStopDaemon(nil, EmptyStreamCallback())
    }
}

#endif
