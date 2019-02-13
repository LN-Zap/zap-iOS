//
//  SwiftBTC
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

private extension URLComponents {
    func queryItem(name: String) -> String? {
        return queryItems?.first(where: { $0.name.lowercased() == name.lowercased() })?.value
    }
}

/// bip-0021 URI scheme for making Bitcoin payments
public struct BitcoinURI: PaymentURI {
    enum Constants {
        static let amount = "amount"
        static let message = "message"
        static let lightning = "lightning"
    }
    
    public let bitcoinAddress: BitcoinAddress
    public var address: String { return bitcoinAddress.string }
    public var network: Network { return bitcoinAddress.network }
    public var isCaseSensitive: Bool { return bitcoinAddress.type != .bech32 || memo != nil }
    public let amount: Satoshi?
    public let memo: String?
    public let lightningFallback: String?
    
    public var uriString: String {
        var urlComponents = URLComponents(string: "bitcoin:\(address)")
        var queryItems = [URLQueryItem]()
        
        if let amount = amount, amount > 0 {
            let amountInBitcoin = CurrencyConverter.convert(amount: amount, from: Bitcoin.satoshi, to: Bitcoin.bitcoin)
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
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let components = URLComponents(string: string),
            let address = BitcoinAddress(string: components.path)
            else { return nil }

        let amount: Satoshi?
        if var amountString = components.queryItem(name: Constants.amount) {
            if let decimalSeparator = Locale.current.decimalSeparator, decimalSeparator != "." {
                amountString = amountString.replacingOccurrences(of: ".", with: decimalSeparator)
            }
            amount = SatoshiFormatter(unit: .bitcoin).satoshis(from: amountString)
        } else {
            amount = nil
        }
        
        let memo = components.queryItem(name: Constants.message)
        let lightningFallback = components.queryItem(name: Constants.lightning)
        
        self.init(address: address, amount: amount, memo: memo, lightningFallback: lightningFallback)
    }
    
    public init?(address: BitcoinAddress, amount: Satoshi?, memo: String?, lightningFallback: String?) {
        self.bitcoinAddress = address
        self.amount = amount
        self.memo = memo
        self.lightningFallback = lightningFallback
    }
}
