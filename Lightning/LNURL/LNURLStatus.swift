//
//  Lightning
//
//  Created by 0 on 11.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public struct LNURLStatus: Decodable {
    public enum Status: String, Codable {
        case ok = "OK" // swiftlint:disable:this identifier_name
        case error = "ERROR"
    }
    
    public let status: Status
    public let reason: String?
}
