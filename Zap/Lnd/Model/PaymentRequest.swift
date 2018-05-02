//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

struct PaymentRequest {
    fileprivate struct PaymentDescription: Decodable {
        let description: String
        
        private enum CodingKeys: String, CodingKey {
            case description = "d"
        }
    }
    
    let amount: Satoshi
    let memo: String?
    let date: Date
    let expiry: Int
    let raw: String
}

extension PaymentRequest {
    init(payReq: Lnrpc_PayReq, raw: String) {
        self.amount = Satoshi(value: payReq.numSatoshis)
        
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
        
        self.date = Date(timeIntervalSince1970: TimeInterval(payReq.timestamp))
        self.expiry = Int(payReq.expiry)
        self.raw = raw
    }
}
