//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension Lnrpc_Invoice {
    enum Template {
        static func create(memo: String, amount: Int64, date: Date) -> Lnrpc_Invoice {
            var invoice = Lnrpc_Invoice()
            invoice.rHash = "l1".data(using: .utf8)! // swiftlint:disable:this force_unwrapping
            invoice.memo = memo
            invoice.value = amount
            invoice.state = .settled
            invoice.creationDate = Int64(date.timeIntervalSince1970)
            invoice.expiry = Int64(date.timeIntervalSince1970)
            invoice.paymentRequest = "abs"
            return invoice

        }
    }
}

extension Lnrpc_ListInvoiceResponse {
    enum Template {
        static func create(invoices: [Lnrpc_Invoice]) -> Lnrpc_ListInvoiceResponse {
            var response = Lnrpc_ListInvoiceResponse()
            response.invoices = invoices
            return response
        }
    }
}

extension Lnrpc_GetInfoResponse {
    enum Template {
        static var testnet: Lnrpc_GetInfoResponse {
            var result = Lnrpc_GetInfoResponse()
            result.alias = "test"
            result.blockHeight = 124123
            result.syncedToChain = true
            var chain = Lnrpc_Chain()
            chain.network = "testnet"
            chain.chain = "bitcoin"
            result.chains = [chain]
            result.identityPubkey = "123123"
            result.numActiveChannels = 2
            result.bestHeaderTimestamp = Int64(Date().timeIntervalSince1970)
            result.uris = []
            result.version = "0.4.2-beta commit=625b210f441ece841c76b81377dd96e8d09aba8e"
            return result
        }

        static var mainnet: Lnrpc_GetInfoResponse {
            var result = Template.testnet
            var chain = Lnrpc_Chain()
            chain.network = "mainnet"
            chain.chain = "bitcoin"
            result.chains = [chain]
            return result
        }
    }
}

extension Lnrpc_Transaction {
    enum Template {
        static var `default` = create(id: "1", amount: 1000000, date: Date())

        static func create(id: String, amount: Int64, date: Date) -> Lnrpc_Transaction {
            var transaction = Lnrpc_Transaction()
            transaction.txHash = id
            transaction.amount = amount
            transaction.timeStamp = Int64(date.timeIntervalSince1970)
            transaction.totalFees = 12400
            transaction.destAddresses = [

            ]
            transaction.blockHeight = 10
            return transaction
        }
    }

}

extension Lnrpc_Payment {
    enum Template {
        static var `default` = create(id: "l1", amount: 1645, date: Date(), destination: "abc")

        static func create(id: String, amount: Int64, date: Date, destination: String) -> Lnrpc_Payment {
            var payment = Lnrpc_Payment()
            payment.paymentHash = id
            payment.value = amount
            payment.creationDate = Int64(date.timeIntervalSince1970)
            payment.fee = 12
            payment.path = [destination]
            return payment
        }
    }
}

extension Lnrpc_ListChannelsResponse {
    enum Template {
        static let `default` = create(channels: [Lnrpc_Channel.Template.default])

        static func create(channels: [Lnrpc_Channel]) -> Lnrpc_ListChannelsResponse {
            var result = Lnrpc_ListChannelsResponse()
            result.channels = channels
            return result
        }
    }
}

extension Lnrpc_Channel {
    enum Template {
        static let `default` = create(active: true, localBalance: 100, remoteBalance: 100, remotePubKey: "abc")

        static func create(active: Bool, localBalance: Int64, remoteBalance: Int64, remotePubKey: String) -> Lnrpc_Channel {
            var channel = Lnrpc_Channel()
            channel.active = active
            channel.localBalance = localBalance
            channel.remoteBalance = remoteBalance
            channel.remotePubkey = remotePubKey
            return channel
        }
    }
}

extension Lnrpc_WalletBalanceResponse {
    enum Template {
        static func create(confirmedBalance: Int64, unconfirmedBalance: Int64) -> Lnrpc_WalletBalanceResponse {
            var balance = Lnrpc_WalletBalanceResponse()
            balance.confirmedBalance = confirmedBalance
            balance.unconfirmedBalance = unconfirmedBalance
            return balance
        }
    }
}

extension Lnrpc_TransactionDetails {
    enum Template {
        static func create(transactions: [Lnrpc_Transaction]) -> Lnrpc_TransactionDetails {
            var response = Lnrpc_TransactionDetails()
            response.transactions = transactions
            return response
        }
    }
}

extension Lnrpc_ListPaymentsResponse {
    enum Template {
        static func create(payments: [Lnrpc_Payment]) -> Lnrpc_ListPaymentsResponse {
            var response = Lnrpc_ListPaymentsResponse()
            response.payments = payments
            return response
        }
    }
}

extension ChannelPoint {
    static var template: ChannelPoint {
        return ChannelPoint(string: "t1:123")
    }
}

extension Lnrpc_PayReq {
    enum Template {
        static var testnet: Lnrpc_PayReq {
            var payReq = Lnrpc_PayReq()
            payReq.paymentHash = "444663acd9833c2a05ba0a481a8800f97e0ae12066eadd65993edcbcbdbee11b"
            payReq.destination = "03e50492eab4107a773141bb419e107bda3de3d55652e6e1a41225f06a0bbf2d56"
            payReq.numSatoshis = 150_000
            payReq.description_p = "Read: Opinion Editorial: Crypto Wolves"
            payReq.timestamp = Int64(Date().timeIntervalSince1970)
            payReq.expiry = Int64(Date().addingTimeInterval(3600).timeIntervalSince1970)
            return payReq
        }

        static var testnetFallback: Lnrpc_PayReq {
            var payReq = Lnrpc_PayReq()
            payReq.paymentHash = "444663acd9833c2a05ba0a481a8800f97e0ae12066eadd65993edcbcbdbee11b"
            payReq.destination = "03e50492eab4107a773141bb419e107bda3de3d55652e6e1a41225f06a0bbf2d56"
            payReq.numSatoshis = 150_000
            payReq.description_p = "Read: Opinion Editorial: Crypto Wolves"
            payReq.timestamp = Int64(Date().timeIntervalSince1970)
            payReq.expiry = Int64(Date().addingTimeInterval(3600).timeIntervalSince1970)
            payReq.fallbackAddr = "mzMD4CTKR6Essspredb5MSBPECtJrnVgBC"
            return payReq
        }
    }
}

extension Lnrpc_SendResponse {
    enum Template {
        static var `default`: Lnrpc_SendResponse {
            let response = Lnrpc_SendResponse()

            return response
        }
    }
}
