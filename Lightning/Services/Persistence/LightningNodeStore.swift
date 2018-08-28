//
//  Zap
//
//  Created by Otto Suess on 21.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

// TODO: remove channel Service reference
public final class LightningNodeStore: Persistable {
    public typealias Value = [String: LightningNode]

    public static var fileName = "nodeStore"
    public var data = [String: LightningNode]()
    private let channelService: ChannelService
    
    public init(channelService: ChannelService) {
        self.channelService = channelService
        
        loadPersistable()
    }
    
    public func node(for remotePubkey: String, completion: @escaping (LightningNode?) -> Void) {
        if let node = data[remotePubkey] {
            completion(node)
        } else {
            channelService.node(for: remotePubkey) { [weak self] in
                completion($0)
                
                if let node = $0 {
                    self?.data[remotePubkey] = node
                    self?.savePersistable()
                }
            }
        }
    }
}
