//
//  Zap
//
//  Created by Otto Suess on 20.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import KeychainAccess

public struct RemoteNodeConfiguration: Codable {
    let remoteNodeCertificates: RemoteNodeCertificates
    let url: URL
    
    static private let keychain = Keychain(service: "com.jackmallers.zap")
    
    func save() {
        guard
            let data = try? JSONEncoder().encode(self)
            else { return }
        
        let keychain = RemoteNodeConfiguration.keychain
        keychain[data: "remoteNodeConfiguration"] = data
    }
    
    static func load() -> RemoteNodeConfiguration? {
        let keychain = RemoteNodeConfiguration.keychain
        guard let data = keychain[data: "remoteNodeConfiguration"] else { return nil }
        return try? JSONDecoder().decode(self, from: data)
    }
    
    static func delete() {
        try? keychain.remove("remoteNodeConfiguration")
    }
}
