//
//  SwiftLnd
//
//  Created by Otto Suess on 15.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct Macaroon: Codable, Equatable {
    let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public init(from decoder: Decoder) throws {
        data = try Data(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try data.encode(to: encoder)
    }
    
    public init?(hexadecimalString: String) {
        guard let data = Data(hexadecimalString: hexadecimalString) else { return nil }
        self.data = data
    }
    
    public init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        self.data = data
    }
    
    public var hexadecimalString: String {
        return data.hexString()
    }
}
