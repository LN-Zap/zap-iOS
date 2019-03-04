//
//  ZapShared
//
//  Created by Otto Suess on 26.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct RPCCredentials: Codable, Equatable {
    public let certificate: String?
    public let macaroon: Macaroon
    public let host: URL

    public init(certificate: String?, macaroon: Macaroon, host: URL) {
        self.certificate = certificate
        self.macaroon = macaroon
        self.host = host
    }

    enum CodingKeys: String, CodingKey {
        case certificate, macaroon
        case host = "url" // host used to be called url, 
    }
}
