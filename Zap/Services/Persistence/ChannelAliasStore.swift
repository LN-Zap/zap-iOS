//
//  Zap
//
//  Created by Otto Suess on 21.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class ChannelAliasStore: Persistable {
    typealias Value = String

    var fileName = "channelAliases"
    var data = [String: String]()
    private let api: LightningProtocol
    
    init(api: LightningProtocol) {
        self.api = api
        
        loadPersistable()
    }
    
    func alias(for remotePubkey: String, callback: @escaping (String) -> Void) {
        if let alias = data[remotePubkey] {
            callback(alias)
        } else {
            api.nodeInfo(pubKey: remotePubkey) { [weak self] result in
                guard
                    let nodeInfo = result.value,
                    let alias = nodeInfo.node.alias,
                    alias != ""
                    else { return }
                callback(alias)
                
                self?.data[remotePubkey] = alias
                self?.savePersistable()
            }
        }
    }
}
