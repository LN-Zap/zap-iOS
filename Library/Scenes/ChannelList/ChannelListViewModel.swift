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
    private let aliasStore: ChannelAliasStore
    
    let sections: MutableObservable2DArray<String, ChannelViewModel>
    let searchString = Observable<String?>(nil)
    
    init(channelService: ChannelService, aliasStore: ChannelAliasStore) {
        self.channelService = channelService
        self.aliasStore = aliasStore
        
        sections = MutableObservable2DArray()
        
        super.init()
        
        combineLatest(channelService.open, channelService.pending, searchString)
            .observeOn(DispatchQueue.main)
            .observeNext(with: updateChannels)
            .dispose(in: reactive.bag)
    }
    
    private func updateChannels(open: [Channel], pending: [Channel], searchString: String?) {
        let result = MutableObservable2DArray<String, ChannelViewModel>()
        
        addSection(for: pending, metadata: "scene.channels.section_header.pending".localized, searchString: searchString, to: result)
        addSection(for: open, metadata: "scene.channels.section_header.open".localized, searchString: searchString, to: result)
        
        sections.replace(with: result, performDiff: true)
    }
    
    private func addSection(for channels: [Channel], metadata: String, searchString: String?, to result: MutableObservable2DArray<String, ChannelViewModel>) {
        let channelViewModels = channels
            .map { ChannelViewModel(channel: $0, aliasStore: aliasStore) }
            .filter { $0.matchesSearchString(searchString) }
    
        guard !channelViewModels.isEmpty else { return }
        
        let section = Observable2DArraySection<String, ChannelViewModel>(metadata: metadata, items: channelViewModels)
        result.appendSection(section)
    }
    
    func refresh() {
        channelService.update()
    }
    
    func close(_ channel: Channel) {
        channelService.close(channel)
    }
}
