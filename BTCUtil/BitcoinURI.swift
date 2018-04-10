//
//  BTCUtil
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum BitcoinURI {
    public static func from(address: String, amount: Satoshi? = nil, message: String? = nil) -> String? {
        var urlComponents = URLComponents(string: "bitcoin:\(address)")
        var queryItems = [URLQueryItem]()
        
        if let amount = amount {
            queryItems.append(URLQueryItem(name: "amount", value: amount.convert(to: .bitcoin).stringValue))
        }
        if let message = message {
            queryItems.append(URLQueryItem(name: "message", value: message))
        }
        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }
        
        return urlComponents?.string
    }
}
