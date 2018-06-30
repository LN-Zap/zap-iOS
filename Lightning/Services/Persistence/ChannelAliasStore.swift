//
//  Zap
//
//  Created by Otto Suess on 21.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

// TODO: remove channel Service reference
public final class ChannelAliasStore: Persistable {
    public typealias Value = [String: String]

    public static var fileName = "channelAliases"
    public var data = [String: String]()
    private let channelService: ChannelService
    
    public init(channelService: ChannelService) {
        self.channelService = channelService
        
        loadPersistable()
    }
    
    public func alias(for remotePubkey: String, callback: @escaping (String?) -> Void) {
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
