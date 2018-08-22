//
//  BTCUtil
//
//  Created by Otto Suess on 06.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public struct LightningInvoiceURI: PaymentURI {    
    public let amount: Satoshi?
    public let memo: String?
    public let address: String
    public let network: Network

    public var uriString: String {
        return "lightning:\(address)"
    }
    
    public init?(string: String) {
        var string = string.lowercased()

        let prefix = "lightning:"
        if string.starts(with: prefix) {
            string = String(string.dropFirst(prefix.count))
        }
        
        guard let invoice = Bolt11().decode(string: string) else { return nil }
        
        address = string
        amount = invoice.amount
        memo = invoice.description
        network = invoice.network
    }
}
