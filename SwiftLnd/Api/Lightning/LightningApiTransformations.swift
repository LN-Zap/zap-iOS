//
//  SwiftLnd
//
//  Created by Otto Suess on 29.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import LndRpc
import SwiftBTC

enum LightningApiTransformations {
    static func transactions(input: LNDTransactionDetails) -> [Transaction] {
        return input.transactionsArray.compactMap {
            guard let transaction = $0 as? LNDTransaction else { return nil }
            return Transaction(transaction: transaction)
        }
    }
    
    static func payments(input: LNDListPaymentsResponse) -> [Payment] {
        return input.paymentsArray.compactMap {
            guard let payment = $0 as? LNDPayment else { return nil }
            return Payment(payment: payment)
        }
    }
    
    static func channels(input: LNDListChannelsResponse) -> [Channel] {
        return input.channelsArray.compactMap { ($0 as? LNDChannel)?.channelModel }
    }
    
    static func invoices(input: LNDListInvoiceResponse) -> [Invoice] {
        return input.invoicesArray.compactMap {
            guard let invoice = $0 as? LNDInvoice else { return nil }
            return Invoice(invoice: invoice)
        }
    }
    
    static func peers(input: LNDListPeersResponse) -> [Peer] {
        return input.peersArray.compactMap {
            guard let peer = $0 as? LNDPeer else { return nil }
            return Peer(peer: peer)
        }
    }
    
    static func closedChannels(input: LNDClosedChannelsResponse) -> [ChannelCloseSummary] {
        return input.channelsArray.compactMap {
            guard let channelCloseSummary = $0 as? LNDChannelCloseSummary else { return nil }
            return ChannelCloseSummary(channelCloseSummary: channelCloseSummary)
        }
    }
    
    static func info(input: LNDGetInfoResponse) -> Info {
        return Info(getInfoResponse: input)
    }
    
    static func nodeInfo(input: LNDNodeInfo) -> NodeInfo {
        return NodeInfo(nodeInfo: input)
    }
    
    static func routes(input: LNDQueryRoutesResponse) -> [Route] {
        return input.routesArray.compactMap {
            guard let route = $0 as? LNDRoute else { return nil }
            return Route(route: route)
        }
    }
    
    static func newAddress(input: LNDNewAddressResponse) -> BitcoinAddress? {
        return BitcoinAddress(string: input.address)
    }
    
    static func sendCoins(input: LNDSendCoinsResponse) -> String {
        return input.txid
    }
    
    static func subscribeInvoices(input: LNDInvoice) -> Invoice {
        return Invoice(invoice: input)
    }
    
    static func walletBalance(input: LNDWalletBalanceResponse) -> Satoshi {
        return Satoshi(input.totalBalance)
    }
    
    static func subscribeChannelGraph(input: LNDGraphTopologyUpdate) -> GraphTopologyUpdate {
        return GraphTopologyUpdate(graphTopologyUpdate: input)
    }
    
    static func addInvoice(input: LNDAddInvoiceResponse) -> String {
        return input.paymentRequest
    }
    
    static func sendPayment(paymentRequest: PaymentRequest, amount: Satoshi?) -> (LNDSendResponse) -> Result<Payment, LndApiError> {
        return {
            if let errorMessage = $0.paymentError, !errorMessage.isEmpty {
                return .failure(LndApiError.localizedError(errorMessage))
            } else {
                return .success(Payment(paymentRequest: paymentRequest, sendResponse: $0, amount: amount))
            }
        }
    }

    static func decodePaymentRequest(paymentRequest: String) -> (LNDPayReq) -> PaymentRequest {
        return { PaymentRequest(payReq: $0, raw: paymentRequest) }
    }
    
    static func closeChannel(input: LNDCloseStatusUpdate) -> CloseStatusUpdate {
        return CloseStatusUpdate(closeStatusUpdate: input)
    }
    
    static func openChannel(input: LNDChannelPoint) -> ChannelPoint {
        return ChannelPoint(channelPoint: input)
    }
    
    static func pendingChannels(input: LNDPendingChannelsResponse) -> [Channel] {
        return input.channels
    }
    
    static func channelBalance(input: LNDChannelBalanceResponse) -> Satoshi {
        return Satoshi(input.balance)
    }
    
    static func subscribeTransactions(input: LNDTransaction) -> Transaction {
        return Transaction(transaction: input)
    }
    
    static func connect(input: LNDConnectPeerResponse) -> Success {
        return Success()
    }
}
