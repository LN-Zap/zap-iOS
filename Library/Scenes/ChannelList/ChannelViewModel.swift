//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning

final class ChannelViewModel {
    let channel: Channel
    
    let state: Observable<ChannelState>
    let name: Observable<String>
    let color: Observable<UIColor>

    var csvDelayTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits =  [.year, .month, .day, .hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        
        let blockTime: TimeInterval = 10 * 60

        return formatter.string(from: TimeInterval(channel.csvDelay) * blockTime) ?? ""
    }
    
    lazy var detailViewModel: ChannelDetailConfiguration = {
        ChannelDetailConfiguration(channelViewModel: self)
    }()
    
    init(channel: Channel, nodeStore: LightningNodeStore) {
        self.channel = channel
        
        name = Observable(channel.remotePubKey)
        state = Observable(channel.state)
        color = Observable(UIColor.Zap.lightningOrange)
        
        nodeStore.node(for: channel.remotePubKey) { [name, color] in
            if let alias = $0?.alias {
                name.value = alias
            }
            if let colorString = $0?.color,
                let newColor = UIColor(hex: colorString) {
                color.value = newColor
            }
        }
    }
    
    func matchesSearchString(_ string: String?) -> Bool {
        guard
            let string = string?.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase,
            !string.isEmpty
            else { return true }
        
        return name.value.localizedLowercase.contains(string)
            || channel.remotePubKey.lowercased().contains(string)
    }
}

extension ChannelViewModel: Equatable {
    static func == (lhs: ChannelViewModel, rhs: ChannelViewModel) -> Bool {
        return lhs.channel == rhs.channel
    }
}
