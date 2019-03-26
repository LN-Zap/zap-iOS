//
//  Library
//
//  Created by Otto Suess on 20.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import LndRpc
import Logger

final class UnlockWalletViewModel {
    private let lightningService: LightningService
    private let walletService: WalletService
    private let configuration: WalletConfiguration

    private var timer: Timer?

    let isUnlocking = Observable(false)
    let nodeAlias: String

    init(lightningService: LightningService, configuration: WalletConfiguration) {
        self.lightningService = lightningService
        self.walletService = WalletService(connection: configuration.connection)
        self.configuration = configuration
        self.nodeAlias = configuration.alias ?? "your Node"
    }

    func unlock(password: String) {
        // Stop updating the wallet state, because lnd needs time to start.
        // During that period the wallet state would be `.error` which would
        // result in a disconnect.
        isUnlocking.value = true
        lightningService.infoService.stop()

        walletService.unlockWallet(password: password) { [weak self] result in
            switch result {
            case .success:
                Toast.presentSuccess("Wallet Unlocked")
                self?.waitWalletReady()
            case .failure(let error):
                Toast.presentError(error.localizedDescription)
                self?.isUnlocking.value = false
            }
        }
    }

    func waitWalletReady() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkInfo()
        }
    }

    private func checkInfo() {
        lightningService.infoService.info { [weak self] in
            self?.lightningService.resetRpcConnection()

            if case .success = $0 {
                Logger.info("wallet started")
                self?.timer?.invalidate()
                self?.lightningService.infoService.start()
            } else {
                Logger.info("waiting for wallet to start")
            }
        }
    }
}
