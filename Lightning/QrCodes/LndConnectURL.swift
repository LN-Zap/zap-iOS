//
//  Lightning
//
//  Created by Otto Suess on 12.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

private extension URL {
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
            else { return nil }

        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}

private extension String {
    func base64UrlToBase64() -> String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }

        return base64
    }
}

public final class LndConnectURL {
    public let rpcConfiguration: RemoteRPCConfiguration

    public init?(url: URL) {
        guard
            let queryParameters = url.queryParameters,
            let nodeHostString = url.host,
            let port = url.port,
            let nodeHostUrl = URL(string: "\(nodeHostString):\(port)"),
            let macaroonString = queryParameters["macaroon"]?.base64UrlToBase64(),
            let macaroon = Macaroon(base64String: macaroonString)
            else { return nil }

        let certString: String?
        if let certificate = queryParameters["cert"]?.base64UrlToBase64() {
            certString = Pem(key: certificate).string
        } else {
            certString = nil
        }

        rpcConfiguration = RemoteRPCConfiguration(certificate: certString, macaroon: macaroon, url: nodeHostUrl)
    }
}
