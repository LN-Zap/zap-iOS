//
//  Lightning
//
//  Created by Otto Suess on 12.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

extension URL {
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

extension String {
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
    
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

public final class RPCConnectURL {
    public let rpcConfiguration: RemoteRPCConfiguration
    
    public init?(string: String) {
        let urlString = string.removingPrefix("zap:").removingPrefix("//")
        
        guard
            let url = URL(string: urlString),
            let queryParameters = url.queryParameters,
            let nodeUrlString = queryParameters["ip"],
            let nodeUrl = URL(string: nodeUrlString),
            let macaroonString = queryParameters["macaroon"]?.base64UrlToBase64(),
            let macaroon = Macaroon(base64String: macaroonString)
            else { return nil }
        
        let certificate = url.path.base64UrlToBase64()
        rpcConfiguration = RemoteRPCConfiguration(certificate: Pem(key: certificate).string, macaroon: macaroon, url: nodeUrl)
    }
}
