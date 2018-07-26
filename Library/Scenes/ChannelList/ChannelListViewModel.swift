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

final class ChannelListViewModel: NSObject {
    private let channelService: ChannelService
    
    let nodeStore: LightningNodeStore
    
    let dataSource: MutableObservableArray<ChannelViewModel>
    let searchString = Observable<String?>(nil)
    
    init(channelService: ChannelService, nodeStore: LightningNodeStore) {
        self.channelService = channelService
        self.nodeStore = nodeStore
        
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
            .map { ChannelViewModel(channel: $0, nodeStore: nodeStore) }
            .filter { $0.matchesSearchString(searchString) }
        
        dataSource.replace(with: viewModels, performDiff: true)
    }
    
    func refresh() {
        channelService.update()
    }
    
    func close(_ channel: Channel, callback: @escaping (Lightning.Result<CloseStatusUpdate>) -> Void) {
        channelService.close(channel, callback: callback)
    }
}
