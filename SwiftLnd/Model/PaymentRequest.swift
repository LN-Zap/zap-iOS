//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftBTC

public struct PaymentRequest: Equatable {
    private struct PaymentDescription: Decodable {
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
    public let fallbackAddress: BitcoinAddress?
    public let network: Network
}

extension PaymentRequest {
    init?(payReq: Lnrpc_PayReq, raw: String) {
        self.amount = Satoshi(payReq.numSatoshis)

        if amount <= 0 {
            return nil
        }

        if let data = payReq.description_p.data(using: .utf8, allowLossyConversion: false) {
            if let json = try? JSONDecoder().decode(PaymentDescription.self, from: data) {
                memo = json.description
            } else if let string = String(data: data, encoding: .utf8) {
                memo = string
            } else {
                memo = nil
            }
        } else {
            memo = nil
        }

        paymentHash = payReq.paymentHash
        destination = payReq.destination
        date = Date(timeIntervalSince1970: TimeInterval(payReq.timestamp))
        expiryDate = Date(timeInterval: TimeInterval(payReq.expiry), since: date)
        if !payReq.fallbackAddr.isEmpty {
            fallbackAddress = BitcoinAddress(string: payReq.fallbackAddr)
        } else {
            fallbackAddress = nil
        }

        var selectedNetwork: Network?
        for network in Network.allCases where raw.hasPrefix(Bolt11.Prefix.forNetwork(network).rawValue) {
            selectedNetwork = network
            break
        }

        if let selectedNetwork = selectedNetwork {
            self.network = selectedNetwork
        } else {
            return nil
        }

        self.raw = raw
    }
}
