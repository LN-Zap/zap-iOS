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

extension Channel.State: Comparable {
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

    public static func < (lhs: Channel.State, rhs: Channel.State) -> Bool {
        return lhs.sortRank < rhs.sortRank
    }
}

final class ChannelListViewModel: NSObject {
    private let lightningService: LightningService

    let dataSource: MutableObservableArray<ChannelViewModel>
    let searchString = Observable<String?>(nil)
    var maxBalance: Satoshi = 1

    let totalLocal = Observable<Satoshi>(0)
    let totalRemote = Observable<Satoshi>(0)
    let totalPending = Observable<Satoshi>(0)
    let totalOffline = Observable<Satoshi>(0)

    let shouldHideEmptyWalletState: Signal<Bool, Never>

    var emptyStateViewModel: WalletEmptyStateViewModel {
        return WalletEmptyStateViewModel(lightningService: lightningService)
    }

    var channelService: ChannelService {
        return lightningService.channelService
    }

    init(lightningService: LightningService) {
        self.lightningService = lightningService

        dataSource = MutableObservableArray()

        shouldHideEmptyWalletState = lightningService.balanceService.onChain
            .map { $0 > 0 }

        super.init()

        combineLatest(channelService.open, channelService.pending, searchString)
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                let (open, pending, searchString) = $0
                self?.updateChannels(open: open.collection, pending: pending.collection, searchString: searchString)
            }
            .dispose(in: reactive.bag)
    }

    private func updateChannels(open: [Channel], pending: [Channel], searchString: String?) {
        let viewModels = (open + pending)
            .map { ChannelViewModel(channel: $0, channelService: channelService) }
            .filter { $0.matchesSearchString(searchString) }

        let sortedViewModels = viewModels.sorted {
            if $0.channel.state != $1.channel.state {
                return $0.channel.state < $1.channel.state
            } else {
                return $0.channel.remotePubKey < $1.channel.remotePubKey
            }
        }

        maxBalance = viewModels
            .flatMap { [$0.channel.localBalance, $0.channel.remoteBalance] }
            .max() ?? 0

        dataSource.replace(with: sortedViewModels, performDiff: true)

        totalLocal.value = open.reduce(0) { $0 + ($1.state == .active ? $1.localBalance : 0) }
        totalRemote.value = open.reduce(0) { $0 + ($1.state == .active ? $1.remoteBalance : 0) }
        totalOffline.value = open.reduce(0) { $0 + ($1.state == .inactive ? $1.localBalance : 0) }
        totalPending.value = pending.reduce(0) { $0 + $1.localBalance }
    }

    func close(_ channel: Channel, completion: @escaping ApiCompletion<CloseStatusUpdate>) {
        channelService.close(channel, completion: completion)
    }

    func refresh() {
        channelService.update()
    }
}
