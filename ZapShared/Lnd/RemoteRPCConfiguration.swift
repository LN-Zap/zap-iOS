//
//  ZapShared
//
//  Created by Otto Suess on 26.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import KeychainAccess

public struct RemoteRPCConfiguration: Codable {
    let certificate: String
    let macaroon: Data
    let url: URL
    
    static private let keychain = Keychain(service: "com.jackmallers.zap")
    
    func save() {
        guard
            let data = try? JSONEncoder().encode(self)
            else { return }
        
        let keychain = RemoteRPCConfiguration.keychain
        keychain[data: "remoteNodeConfiguration"] = data
    }
    
    static func load() -> RemoteRPCConfiguration? {
        let keychain = RemoteRPCConfiguration.keychain
        guard let data = keychain[data: "remoteNodeConfiguration"] else { return nil }
        return try? JSONDecoder().decode(self, from: data)
    }
    
    static func delete() {
        try? keychain.remove("remoteNodeConfiguration")
    }
}
