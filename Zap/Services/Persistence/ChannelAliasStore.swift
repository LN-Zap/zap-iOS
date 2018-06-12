//
//  Zap
//
//  Created by Otto Suess on 21.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

// TODO: remove channel Service reference
final class ChannelAliasStore: Persistable {
    typealias Value = [String: String]

    static var fileName = "channelAliases"
    var data = [String: String]()
    private let channelService: ChannelService
    
    init(channelService: ChannelService) {
        self.channelService = channelService
        
        loadPersistable()
    }
    
    func alias(for remotePubkey: String, callback: @escaping (String?) -> Void) {
        if let alias = data[remotePubkey] {
            callback(alias)
        } else {
            channelService.alias(for: remotePubkey) { [weak self] in
                callback($0)
                
                if let alias = $0 {
                    self?.data[remotePubkey] = alias
                    self?.savePersistable()
                }
            }
        }
    }
}
