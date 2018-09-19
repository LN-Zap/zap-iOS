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
        }
    }
    
    public static func < (lhs: ChannelState, rhs: ChannelState) -> Bool {
        return lhs.sortRank < rhs.sortRank
    }
}

final class ChannelListViewModel: NSObject {
    private let channelService: ChannelService
    
    let dataSource: MutableObservableArray<ChannelViewModel>
    let searchString = Observable<String?>(nil)
    
    init(channelService: ChannelService) {
        self.channelService = channelService
        
        dataSource = MutableObservableArray()
        
        super.init()
        
        combineLatest(channelService.open, channelService.pending, searchString)
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                self?.updateChannels(open: $0, pending: $1, searchString: $2)
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
        
        dataSource.replace(with: sortedViewModels, performDiff: true)
    }
    
    func refresh() {
        channelService.update()
    }
    
    func close(_ channel: Channel, completion: @escaping (SwiftLnd.Result<CloseStatusUpdate>) -> Void) {
        channelService.close(channel, completion: completion)
    }
}
