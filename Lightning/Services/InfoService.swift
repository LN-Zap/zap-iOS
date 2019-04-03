//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import SwiftBTC
import SwiftLnd

public final class InfoService {
    public enum WalletState {
        case connecting
        case locked
        case syncing
        case running
        case error
    }

    private let api: LightningApiProtocol

    public let balanceService: BalanceService

    public let bestHeaderDate = Observable<Date?>(nil)
    public let blockChainHeight = Observable<Int?>(nil)
    public let blockHeight = Observable<Int?>(nil)
    public let network = Observable<Network?>(nil)
    public var info = Observable<Info?>(nil)
    public var walletState = Observable<WalletState>(.connecting)

    private var heightJobTimer: Timer?
    private var updateInfoTimer: Timer?

    private var syncDebounceCount = 0 // used so wallet does not switch sync state each time a block is mined

    init(api: LightningApiProtocol, balanceService: BalanceService) {
        self.api = api
        self.balanceService = balanceService

        start()
    }

    public func start() {
        heightJobTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            guard let network = self?.network.value else { return }
            BlockchainHeight.get(for: network) { self?.blockChainHeight.value = $0 }
        }
        heightJobTimer?.fire()

        updateInfoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.info { self?.updateInfo(result: $0) }
        }
        updateInfoTimer?.fire()
    }

    public func info(completion: @escaping (Result<Info, LndApiError>) -> Void) {
        api.info(completion: completion)
    }

    private func stateFor(_ result: Result<Info, LndApiError>) -> WalletState {
        switch result {
        case .success(let info):
            if info.isSyncedToChain {
                return .running
            } else {
                return .syncing
            }
        case .failure(let error):
            switch error {
            case .walletEncrypted:
                return .locked
            default:
                return .error
            }
        }
    }

    private func updateInfo(result: Result<Info, LndApiError>) {
        let newState = stateFor(result)

        if walletState.value != newState {
            // only switch from .running to .syncing after several info updates with .syncing state
            if walletState.value == .running && newState == .syncing && syncDebounceCount < 10 {
                syncDebounceCount += 1
                Logger.info("debounce sync: \(syncDebounceCount)", customPrefix: "🧯")
            } else {
                syncDebounceCount = 0
                walletState.value = newState
            }
        }
        if walletState.value == .running {
            // if the state does not switch to syncing because of debouncing syncDebounceCount needs to be reset anyway
            syncDebounceCount = 0
        }

        if case .success(let info) = result {
            if blockHeight.value != info.blockHeight {
                blockHeight.value = info.blockHeight
            }
            if bestHeaderDate.value != info.bestHeaderDate {
                bestHeaderDate.value = info.bestHeaderDate
            }
            if network.value != info.network {
                network.value = info.network
                heightJobTimer?.fire()
            }
        }

        let newIsSyncedToChain = (try? result.get())?.isSyncedToChain
        if info.value?.isSyncedToChain != newIsSyncedToChain && newIsSyncedToChain == true {
            balanceService.update()
        }

        self.info.value = try? result.get()
    }

    public func stop() {
        heightJobTimer?.invalidate()
        updateInfoTimer?.invalidate()
    }
}
