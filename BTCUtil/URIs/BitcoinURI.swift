//
//  BTCUtil
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

private extension URLComponents {
    func queryItem(name: String) -> String? {
        return queryItems?.first(where: { $0.name == name })?.value
    }
}

public struct BitcoinURI: PaymentURI {
    enum Constants {
        static let amount = "amount"
        static let message = "message"
        static let lightning = "lightning"
    }
    
    public let address: String
    public let amount: Satoshi?
    public let memo: String?
    public let network: Network
    public let lightningFallback: String?
    
    public var addressOrURI: String {
        if (amount == nil || amount == 0) && (memo == nil || memo?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true) {
            return address
        }
        return stringValue
    }
    
    public var stringValue: String {
        var urlComponents = URLComponents(string: "bitcoin:\(address)")
        var queryItems = [URLQueryItem]()
        
        if let amount = amount, amount > 0 {
            let amountInBitcoin = amount.convert(to: .bitcoin)
            let usLocale = Locale(identifier: "en_US")
            let amountString = (amountInBitcoin as NSDecimalNumber).description(withLocale: usLocale)
            queryItems.append(URLQueryItem(name: Constants.amount, value: amountString))
        }
        if let memo = memo, !memo.isEmpty {
            queryItems.append(URLQueryItem(name: Constants.message, value: memo))
        }
        if let lightningFallback = lightningFallback, !lightningFallback.isEmpty {
            queryItems.append(URLQueryItem(name: Constants.lightning, value: lightningFallback))
        }
        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }
        
        return urlComponents?.string ?? "bitcoin:\(address)"
    }
    
    public init?(string: String) {
        guard let components = URLComponents(string: string) else { return nil }

        let amount: Satoshi?
        if var amountString = components.queryItem(name: Constants.amount) {
            if let decimalSeparator = Locale.current.decimalSeparator, decimalSeparator != "." {
                amountString = amountString.replacingOccurrences(of: ".", with: decimalSeparator)
            }
            amount = Bitcoin(unit: .bitcoin).satoshis(from: amountString)
        } else {
            amount = nil
        }
        
        let memo = components.queryItem(name: Constants.message)
        let lightningFallback = components.queryItem(name: Constants.lightning)
        
        self.init(address: components.path, amount: amount, memo: memo, lightningFallback: lightningFallback)
    }
    
    public init?(address: String, amount: Satoshi?, memo: String?, lightningFallback: String?) {
        if let (humanReadablePart, _) = Bech32.decode(address) {
            if humanReadablePart.lowercased() == "tb" {
                network = .testnet
            } else if humanReadablePart.lowercased() == "bc" {
                network = .mainnet
            } else {
                return nil
            }
        } else if let bitcoinAddress = BitcoinAddress(string: address),
            bitcoinAddress.type != .privateKey {
            self.network = bitcoinAddress.network
        } else {
            return nil
        }
        
        self.address = address
        self.amount = amount
        self.memo = memo
        self.lightningFallback = lightningFallback
    }
}
