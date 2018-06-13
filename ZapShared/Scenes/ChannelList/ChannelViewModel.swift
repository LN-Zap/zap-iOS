//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class ChannelViewModel {
    let channel: Channel
    
    let state: Observable<ChannelState>
    let name: Observable<String>
    
    init(channel: Channel, aliasStore: ChannelAliasStore) {
        self.channel = channel
        
        name = Observable(channel.remotePubKey)
        state = Observable(channel.state)

        aliasStore.alias(for: channel.remotePubKey) { [name] in
            guard let alias = $0 else { return }
            name.value = alias
        }
    }
}

extension ChannelViewModel: Equatable {
    static func == (lhs: ChannelViewModel, rhs: ChannelViewModel) -> Bool {
        return lhs.channel == rhs.channel
    }
}
