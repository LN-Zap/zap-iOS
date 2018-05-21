//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct RemoteNodeCertificates: Codable {
    let certificate: String
    let macaron: Data
    
    enum CodingKeys: String, CodingKey {
        case certificate = "c"
        case macaron = "m"
    }
    
    init?(json: String) {
        guard
            let data = json.data(using: .utf8),
            let remoteNodeCertificates = RemoteNodeCertificates(data: data)
            else { return nil }
        self = remoteNodeCertificates
    }
    
    private init?(data: Data) {
        guard let remoteNodeCertificates = try? JSONDecoder().decode(RemoteNodeCertificates.self, from: data) else { return nil }
        self = remoteNodeCertificates
    }
}
