//
//  ZapShared
//
//  Created by Otto Suess on 26.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import KeychainAccess

public struct RemoteRPCConfiguration: Codable {
    public let certificate: String?
    public let macaroon: Data
    public let url: URL
    
    public init(certificate: String?, macaroon: Data, url: URL) {
        self.certificate = certificate
        self.macaroon = macaroon
        self.url = url
    }
}

extension RemoteRPCConfiguration {
    private static let keychain = Keychain(service: "com.jackmallers.zap")

    public func save() {
        guard
            let data = try? JSONEncoder().encode(self)
            else { return }
        
        let keychain = RemoteRPCConfiguration.keychain
        keychain[data: "remoteNodeConfiguration"] = data
    }
    
    public static func load() -> RemoteRPCConfiguration? {
        let keychain = RemoteRPCConfiguration.keychain
        guard let data = keychain[data: "remoteNodeConfiguration"] else { return nil }
        return try? JSONDecoder().decode(self, from: data)
    }
    
    public static func delete() {
        try? keychain.remove("remoteNodeConfiguration")
    }
}
