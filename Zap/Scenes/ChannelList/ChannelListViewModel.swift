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
    let sections: MutableObservable2DArray<String, Channel>
    
    init(viewModel: ViewModel) {
        sections = MutableObservable2DArray()
        
        super.init()
        
        combineLatest(viewModel.channels, viewModel.pendingChannels) { return ($0, $1) }
            .observeNext { [weak self] open, pending in
                let result = MutableObservable2DArray<String, Channel>()
                
                if !pending.isEmpty {
                    result.appendSection(
                        Observable2DArraySection<String, Channel>(
                            metadata: "scene.channels.section_header.pending".localized,
                            items: pending
                        )
                    )
                }
                if !open.isEmpty {
                    result.appendSection(
                        Observable2DArraySection<String, Channel>(
                            metadata: "scene.channels.section_header.open".localized,
                            items: open
                        )
                    )
                }
                
                self?.sections.replace(with: result, performDiff: true)
            }
            .dispose(in: reactive.bag)
    }
}
