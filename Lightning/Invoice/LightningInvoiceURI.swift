//
//  Lightning
//
//  Created by Otto Suess on 06.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC
import SwiftLnd

public struct LightningInvoiceURI: PaymentURI {
    public let amount: Satoshi?
    public let memo: String?
    public let address: String
    public let network: Network
    public var isCaseSensitive = false
    private static let lightningPrefix = "lightning:"
    
    public var uriString: String {
        return "lightning:\(address)"
    }
    
    public init?(string: String) {
        guard let invoice = LightningInvoiceURI.decode(string: string) else { return nil }
        
        address = string
        amount = invoice.amount
        memo = invoice.description
        network = invoice.network
    }
    
    public init?(invoice: Invoice) {
        self.init(string: invoice.paymentRequest)
    }
    
    public static func validate(string: String) -> Bool {
        return decode(string: string) != nil
    }
    
    private static func decode(string: String) -> Bolt11.Invoice? {
        var string = string.lowercased()
        
        if string.starts(with: lightningPrefix) {
            string = String(string.dropFirst(lightningPrefix.count))
        }
        
        return Bolt11.decode(string: string)
    }
}
