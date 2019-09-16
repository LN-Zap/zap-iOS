//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public enum ApiMockTemplate {
    case syncedEmpty
    case oneChannel
    case manyChannels
    case balance
    case mainnet
    case transactions
    case everything
    case screenshots

    public static let selected: ApiMockTemplate = .transactions

    var instance: LightningConnection {
        switch self {
        case .syncedEmpty:
            return MockLightningConnection(
                getInfo: Lnrpc_GetInfoResponse.Template.testnet
            )
        case .oneChannel:
            return MockLightningConnection(
                getInfo: Lnrpc_GetInfoResponse.Template.testnet,
                listChannels: Lnrpc_ListChannelsResponse.Template.default
            )
        case .manyChannels:
            return MockLightningConnection(
                getInfo: Lnrpc_GetInfoResponse.Template.testnet,
                listChannels: Lnrpc_ListChannelsResponse.Template.create(channels: Array(repeating: Lnrpc_Channel.Template.default, count: 200))
            )
        case .balance:
            return MockLightningConnection(
                walletBalance: Lnrpc_WalletBalanceResponse.Template.create(confirmedBalance: 4_200_000, unconfirmedBalance: 0),
                getInfo: Lnrpc_GetInfoResponse.Template.testnet
            )
        case .mainnet:
            return MockLightningConnection(
                getInfo: Lnrpc_GetInfoResponse.Template.mainnet
            )
        case .transactions:
            return MockLightningConnection(
                walletBalance: Lnrpc_WalletBalanceResponse.Template.create(confirmedBalance: 10_000, unconfirmedBalance: 0),
                getTransactions: Lnrpc_TransactionDetails.Template.create(transactions: [
                    Lnrpc_Transaction.Template.default
                ]),
                getInfo: Lnrpc_GetInfoResponse.Template.testnet,
                listPayments: Lnrpc_ListPaymentsResponse.Template.create(payments: [
                    Lnrpc_Payment.Template.default
                ])
            )
        case .everything:
            return MockLightningConnection(
                walletBalance: Lnrpc_WalletBalanceResponse.Template.create(confirmedBalance: 10_000, unconfirmedBalance: 0),
                getTransactions: Lnrpc_TransactionDetails.Template.create(transactions: [
                    Lnrpc_Transaction.Template.default
                ]),
                getInfo: Lnrpc_GetInfoResponse.Template.testnet,
                listChannels: Lnrpc_ListChannelsResponse.Template.default,
                sendPaymentSync: Lnrpc_SendResponse.Template.default,
                decodePayReq: Lnrpc_PayReq.Template.testnetFallback,
                listPayments: Lnrpc_ListPaymentsResponse.Template.create(payments: [
                    Lnrpc_Payment.Template.default
                ])
            )
        case .screenshots:
            return MockLightningConnection(
                walletBalance: Lnrpc_WalletBalanceResponse.Template.create(confirmedBalance: 420_000, unconfirmedBalance: 0),
                getTransactions: Lnrpc_TransactionDetails.Template.create(transactions: [
                    Lnrpc_Transaction.Template.create(id: "t1", amount: 100000, date: .ago(minutes: 1)),
                    Lnrpc_Transaction.Template.create(id: "t2", amount: -2005000, date: .ago(minutes: 3))
                ]),
                getInfo: Lnrpc_GetInfoResponse.Template.mainnet,

                listChannels: Lnrpc_ListChannelsResponse.Template.create(channels: [
                    Lnrpc_Channel.Template.create(active: true, localBalance: 90950, remoteBalance: 0, remotePubKey: "LightningPowerUsers"),
                    Lnrpc_Channel.Template.create(active: true, localBalance: 30026, remoteBalance: 69788, remotePubKey: "ACINQ"),
                    Lnrpc_Channel.Template.create(active: true, localBalance: 0, remoteBalance: 167545, remotePubKey: "ln1.satoshilabs.com"),
                    Lnrpc_Channel.Template.create(active: true, localBalance: 90950, remoteBalance: 10305, remotePubKey: "tippin.me"),
                    Lnrpc_Channel.Template.create(active: true, localBalance: 157555, remoteBalance: 3450, remotePubKey: "yalls.org"),
                    Lnrpc_Channel.Template.create(active: false, localBalance: 166862, remoteBalance: 20120, remotePubKey: "Bitrefill.com"),
                    Lnrpc_Channel.Template.create(active: false, localBalance: 184824, remoteBalance: 4839, remotePubKey: "03a2fc4acb9691cab0d85")
                ]),
                listInvoices: Lnrpc_ListInvoiceResponse.Template.create(invoices: [
                    Lnrpc_Invoice.Template.create(memo: "Beers at Room77", amount: 1250277, date: .ago(minutes: 10))
                ]),
                listPayments: Lnrpc_ListPaymentsResponse.Template.create(payments: [
                    Lnrpc_Payment.Template.create(id: "l5", amount: -1920, date: .ago(hours: 1), destination: "yalls.org"),
                    Lnrpc_Payment.Template.create(id: "l6", amount: -1, date: .ago(hours: 2), destination: "tippin.me"),
                    Lnrpc_Payment.Template.create(id: "l7", amount: -400, date: .ago(hours: 3), destination: "tippin.me")
                ])
            )
        }
    }
}

extension Date {
    static func ago(seconds: Double = 0, minutes: Double = 0, hours: Double = 0, days: Double = 0) -> Date {
        return Date().addingTimeInterval(-(seconds + minutes * 60 + hours * 60 * 60 + days * 60 * 60 * 24))
    }
}
