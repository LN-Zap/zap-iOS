//
//  Zap
//
//  Created by Otto Suess on 20.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct RemoteNodeConfiguration: Codable {
    let remoteNodeCertificates: RemoteNodeCertificates
    let url: URL
    
    private static var url: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("remoteCertificates.json")
    }
    
    func save() {
        // TODO: save in keychain instead of documents folder
        guard
            let url = RemoteNodeConfiguration.url,
            let data = try? JSONEncoder().encode(self)
            else { return }
        
        try? data.write(to: url)
    }
    
    static func load() -> RemoteNodeConfiguration? {
        guard
            let url = RemoteNodeConfiguration.url,
            let data = try? Data(contentsOf: url)
            else { return nil }
        return try? JSONDecoder().decode(RemoteNodeConfiguration.self, from: data)
    }
}
