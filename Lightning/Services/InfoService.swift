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

    private let api: LightningApi

    public let balanceService: BalanceService

    public let bestHeaderDate = Observable<Date?>(nil)
    public let blockChainHeight = Observable<Int?>(nil)
    public let blockHeight = Observable<Int?>(nil)
    public let network = Observable<Network?>(nil)
    public var info = Observable<Info?>(nil)
    public var walletState = Observable<WalletState>(.connecting)

    private var heightJobTimer: Timer?
    private var updateInfoTimer: Timer?
    private var timeoutTimer: Timer?

    private let staticChannelBackupper: StaticChannelBackupper

    init(api: LightningApi, balanceService: BalanceService, staticChannelBackupper: StaticChannelBackupper) {
        self.api = api
        self.balanceService = balanceService
        self.staticChannelBackupper = staticChannelBackupper

        start()
    }

    public func start() {
        heightJobTimer?.invalidate()
        heightJobTimer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            guard let network = self?.network.value else { return }
            BlockchainHeight.get(for: network) { self?.blockChainHeight.value = $0 }
        }
        heightJobTimer?.fire()

        updateInfoTimer?.invalidate()
        updateInfoTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.info { self?.updateInfo(result: $0) }
        }
        updateInfoTimer?.fire()

        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if case .connecting = self.walletState.value {
                self.walletState.value = .error
            }
        }
    }

    public func info(completion: @escaping ApiCompletion<Info>) {
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
            walletState.value = newState
        }

        if case .success(let info) = result {
            staticChannelBackupper.nodePubKey = info.pubKey

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

        let newInfo: Info?
        switch result {
        case .success(let info):
            newInfo = info
        case .failure:
            newInfo = nil
        }

        let newIsSyncedToChain = newInfo?.isSyncedToChain
        if info.value?.isSyncedToChain != newIsSyncedToChain && newIsSyncedToChain == true {
            balanceService.update()
        }

        self.info.value = newInfo
    }

    public func stop() {
        heightJobTimer?.invalidate()
        updateInfoTimer?.invalidate()
    }
}
