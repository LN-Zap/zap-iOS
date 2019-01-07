//
//  Lightning
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

private struct BTCPayConfigurationJSON: Decodable {
    let configurations: [BTCPayConfigurationItem]
}

private struct BTCPayConfigurationItem: Decodable {
    let type: String
    let cryptoCode: String
    let host: String
    let port: Int
    let ssl: Bool
    let certificateThumbprint: String?
    let macaroon: String
}

struct BTCPayRPCConfiguration: RemoteRPCConfigurationType {
    var rpcConfiguration: RemoteRPCConfiguration

    init?(data: Data) {
        guard
            let json = try? JSONDecoder().decode(BTCPayConfigurationJSON.self, from: data),
            let item = json.configurations.first(where: { $0.type == "grpc" }),
            let url = URL(string: "\(item.host):\(item.port)"),
            let macaroon = Macaroon(hexadecimalString: item.macaroon)
            else { return nil }
        rpcConfiguration = RemoteRPCConfiguration(certificate: nil, macaroon: macaroon, url: url)
    }
}
