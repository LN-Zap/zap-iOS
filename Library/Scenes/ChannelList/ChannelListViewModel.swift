//
//  Zap
//
//  Created by Otto Suess on 28.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit
import SwiftBTC
import SwiftLnd

extension ChannelState: Comparable {
    var sortRank: Int {
        switch self {
        case .active:
            return 0
        case .opening:
            return 1
        case .forceClosing:
            return 2
        case .closing:
            return 3
        case .inactive:
            return 4
        case .waitingClose:
            return 5
        }
    }

    public static func < (lhs: ChannelState, rhs: ChannelState) -> Bool {
        return lhs.sortRank < rhs.sortRank
    }
}

final class ChannelListViewModel: NSObject {
    private let lightningService: LightningService

    let dataSource: MutableObservableArray<ChannelViewModel>
    var maxBalance: Satoshi = 1

    let totalLocal = Observable<Satoshi>(0)
    let totalRemote = Observable<Satoshi>(0)
    let totalPending = Observable<Satoshi>(0)
    let totalOffline = Observable<Satoshi>(0)

    let shouldHideEmptyWalletState: Signal<Bool, Never>
    let shouldHideChannelListEmptyState: Signal<Bool, Never>

    var channelService: ChannelService {
        return lightningService.channelService
    }

    init(lightningService: LightningService) {
        self.lightningService = lightningService
        self.dataSource = MutableObservableArray()

        self.shouldHideEmptyWalletState = lightningService.balanceService.totalBalance
            .map { $0 > 0 }
            .distinctUntilChanged()

        self.shouldHideChannelListEmptyState = combineLatest(lightningService.balanceService.onChainTotal, dataSource)
            .map { $0 <= 0 || !$1.collection.isEmpty }
            .distinctUntilChanged()

        super.init()
        
        combineLatest(channelService.open, channelService.pending)
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                let (open, pending) = $0
                self?.updateChannels(open: open.collection, pending: pending.collection)
            }
            .dispose(in: reactive.bag)
    }

    private func updateChannels(open: [Channel], pending: [Channel]) {
        let viewModels = (open + pending)
            .map { ChannelViewModel(channel: $0, channelService: channelService) }

        let sortedViewModels = viewModels.sorted {
            if $0.state.value != $1.state.value {
                return $0.state.value < $1.state.value
            } else {
                return $0.remotePubKey < $1.remotePubKey
            }
        }

        maxBalance = viewModels
            .flatMap { [$0.localBalance.value, $0.remoteBalance.value] }
            .max() ?? 0

        dataSource.replace(with: sortedViewModels, performDiff: true)

        totalLocal.value = open.reduce(0) { $0 + ($1.state == .active ? $1.localBalance : 0) }
        totalRemote.value = open.reduce(0) { $0 + ($1.state == .active ? $1.remoteBalance : 0) }
        totalOffline.value = open.reduce(0) { $0 + ($1.state == .inactive ? $1.localBalance : 0) }
        totalPending.value = pending.reduce(0) { $0 + $1.localBalance }
    }

    func close(_ channelViewModel: ChannelViewModel, completion: @escaping ApiCompletion<CloseStatusUpdate>) {
        channelService.close(channelViewModel.channel, completion: completion)
    }

    func refresh() {
        channelService.update()
    }
}
