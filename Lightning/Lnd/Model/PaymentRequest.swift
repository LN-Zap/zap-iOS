//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

public struct PaymentRequest: Equatable {
    fileprivate struct PaymentDescription: Decodable {
        let description: String
        
        private enum CodingKeys: String, CodingKey {
            case description = "d"
        }
    }
    
    public let paymentHash: String
    public let destination: String
    public let amount: Satoshi
    public let memo: String?
    public let date: Date
    public let expiryDate: Date
    public let raw: String
    public let fallbackAddress: String?
    public let network: Network
}

extension PaymentRequest {
    init(payReq: Lnrpc_PayReq, raw: String) {
        self.amount = Satoshi(payReq.numSatoshis)
        
        if let data = payReq.description_p.data(using: .utf8, allowLossyConversion: false) {
            if let json = try? JSONDecoder().decode(PaymentDescription.self, from: data) {
                self.memo = json.description
            } else if let string = String(data: data, encoding: .utf8) {
                self.memo = string
            } else {
                self.memo = nil
            }
        } else {
            self.memo = nil
        }
        
        paymentHash = payReq.paymentHash
        destination = payReq.destination
        date = Date(timeIntervalSince1970: TimeInterval(payReq.timestamp))
        expiryDate = Date(timeInterval: TimeInterval(payReq.expiry), since: date)
        fallbackAddress = payReq.fallbackAddr
        
        guard let network = LightningInvoiceURI(string: raw)?.network else { fatalError("Error decoding payment request: \(raw)") }
        self.network = network
        
        self.raw = raw
    }
}
