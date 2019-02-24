//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
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
    public let channelService: ChannelService
    public let historyService: HistoryService

    public let bestHeaderDate = Observable<Date?>(nil)
    public let blockChainHeight = Observable<Int?>(nil)
    public let blockHeight = Observable<Int?>(nil)
    public let network = Observable<Network?>(nil)
    public var info = Observable<Info?>(nil)
    public var walletState = Observable<WalletState>(.connecting)

    private var heightJobTimer: Timer?
    private var updateInfoTimer: Timer?

    init(api: LightningApiProtocol, channelService: ChannelService, balanceService: BalanceService, historyService: HistoryService) {
        self.api = api

        self.channelService = channelService
        self.balanceService = balanceService
        self.historyService = historyService

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
        walletState.value = stateFor(result)

        if let info = result.value {
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

        let newIsSyncedToChain = result.value?.isSyncedToChain
        if info.value?.isSyncedToChain != newIsSyncedToChain && newIsSyncedToChain != nil {
            channelService.update()
            balanceService.update()
            historyService.update()
        }

        self.info.value = result.value
    }

    public func stop() {
        heightJobTimer?.invalidate()
        updateInfoTimer?.invalidate()
    }
}
