//
//  Lightning
//
//  Created by Otto Suess on 06.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct LightningNodeURI {
    public let pubKey: String
    public let host: String

    public var stringValue: String {
        return "\(pubKey):\(host)"
    }
    
    public init?(string: String) {
        let parts = string
            .split { [":", "@", " "].contains(String($0)) }
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard parts.count >= 2
            && parts.count <= 3
            && parts[0].count == 66
            && parts[0].starts(with: "0")
            else { return nil }
        
        pubKey = String(parts[0])
        host = String(parts[1])
    }
}
