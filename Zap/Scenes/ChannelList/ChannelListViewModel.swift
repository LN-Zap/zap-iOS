//
//  Zap
//
//  Created by Otto Suess on 28.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

final class ChannelListViewModel: NSObject {
    private let channelService: ChannelService
    
    let sections: MutableObservable2DArray<String, ChannelViewModel>
    
    init(channelService: ChannelService, aliasStore: ChannelAliasStore) {
        self.channelService = channelService
        
        sections = MutableObservable2DArray()
        
        super.init()
        
        combineLatest(channelService.open, channelService.pending) { return ($0, $1) }
            .observeNext { [sections] open, pending in
                let result = MutableObservable2DArray<String, ChannelViewModel>()
                
                if !pending.isEmpty {
                    result.appendSection(
                        Observable2DArraySection<String, ChannelViewModel>(
                            metadata: "scene.channels.section_header.pending".localized,
                            items: pending.map { ChannelViewModel(channel: $0, aliasStore: aliasStore) }
                        )
                    )
                }
                if !open.isEmpty {
                    result.appendSection(
                        Observable2DArraySection<String, ChannelViewModel>(
                            metadata: "scene.channels.section_header.open".localized,
                            items: open.map { ChannelViewModel(channel: $0, aliasStore: aliasStore) }
                        )
                    )
                }
                
                DispatchQueue.main.async {
                    sections.replace(with: result, performDiff: true)
                }
            }
            .dispose(in: reactive.bag)
    }
    
    func refresh() {
        channelService.update()
    }
}
