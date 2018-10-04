//
//  ZapShared
//
//  Created by Otto Suess on 26.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

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
