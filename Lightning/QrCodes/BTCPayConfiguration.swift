//
//  Lightning
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

struct BTCPayConfiguration: Decodable {
    let configurations: [BTCPayConfigurationItem]

    init?(data: Data) {
        guard let configuration = try? JSONDecoder().decode(BTCPayConfiguration.self, from: data) else { return nil }
        self = configuration
    }

    var rpcConfiguration: RemoteRPCConfiguration? {
        guard
            let item = configurations.first(where: { $0.type == "grpc" }),
            let url = URL(string: "\(item.host):\(item.port)"),
            let macaroon = Macaroon(hexadecimalString: item.macaroon)
            else { return nil }
        return RemoteRPCConfiguration(certificate: nil, macaroon: macaroon, url: url)
    }
}

struct BTCPayConfigurationItem: Decodable {
    let type: String
    let cryptoCode: String
    let host: String
    let port: Int
    let ssl: Bool
    let certificateThumbprint: String?
    let macaroon: String
}
