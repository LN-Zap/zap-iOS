//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lndmobile

final class LightningStream: LightningProtocol {
    func info(callback: @escaping (Result<Info>) -> Void) {
        LndmobileGetInfo(nil, LndCallback<Lnrpc_GetInfoResponse, Info>(callback, map: Info.init))
    }
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        let data = try? Lnrpc_NodeInfoRequest(pubKey: pubKey).serializedData()
        LndmobileGetNodeInfo(data, LndCallback<Lnrpc_NodeInfo, NodeInfo>(callback, map: NodeInfo.init))
    }
    
    func newAddress(type: OnChainRequestAddressType, callback: @escaping (Result<String>) -> Void) {
        // TODO: move to protoExtension
        let addressType: Lnrpc_NewAddressRequest.AddressType
        switch type {
        case .witnessPubkeyHash:
            addressType = .witnessPubkeyHash
        case .nestedPubkeyHash:
            addressType = .nestedPubkeyHash
        }
        
        let data = try? Lnrpc_NewAddressRequest(type: addressType).serializedData()
        LndmobileNewAddress(data, LndCallback<Lnrpc_NewAddressResponse, String>(callback) { $0.address })
    }
    
    func walletBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        LndmobileWalletBalance(nil, LndCallback<Lnrpc_WalletBalanceResponse, Satoshi>(callback) { Satoshi(value: $0.totalBalance) })
    }
    
    func channelBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        LndmobileChannelBalance(nil, LndCallback<Lnrpc_ChannelBalanceResponse, Satoshi>(callback) { Satoshi(value: $0.balance) })
    }
    
    func transactions(callback: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileGetTransactions(nil, LndCallback<Lnrpc_TransactionDetails, [Transaction]>(callback) {
            $0.transactions.compactMap { OnChainTransaction(transaction: $0) }
        })
    }
    
    func subscribeTransactions(callback: @escaping (Result<Transaction>) -> Void) {
        LndmobileSubscribeTransactions(nil, LndCallback<Lnrpc_Transaction, Transaction>(callback, map: OnChainTransaction.init))
    }
    
    func payments(callback: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileListPayments(nil, LndCallback<Lnrpc_ListPaymentsResponse, [Transaction]>(callback) {
            $0.payments.compactMap { LightningPayment(payment: $0) }
        })
    }
    
    func channels(callback: @escaping (Result<[Channel]>) -> Void) {
        LndmobileListChannels(nil, LndCallback<Lnrpc_ListChannelsResponse, [Channel]>(callback) {
            $0.channels.compactMap { $0.channelModel }
        })
    }
    
    func pendingChannels(callback: @escaping (Result<[Channel]>) -> Void) {
        LndmobilePendingChannels(nil, LndCallback<Lnrpc_PendingChannelsResponse, [Channel]>(callback) {
            let pendingOpenChannels: [Channel] = $0.pendingOpenChannels.compactMap { $0.channelModel }
            let pendingClosingChannels: [Channel] = $0.pendingClosingChannels.compactMap { $0.channelModel }
            let pendingForceClosingChannels: [Channel] = $0.pendingForceClosingChannels.compactMap { $0.channelModel }
            return pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels
        })
    }
    
    func connect(pubKey: String, host: String, callback: @escaping (Result<Void>) -> Void) {
        let data = try? Lnrpc_ConnectPeerRequest(pubKey: pubKey, host: host).serializedData()
        LndmobileConnectPeer(data, LndCallback<Lnrpc_ConnectPeerResponse, Void>(callback) { _ in () })
    }
    
    func openChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<Lnrpc_ChannelPoint>) -> Void) {
        let data = try? Lnrpc_OpenChannelRequest(pubKey: pubKey, amount: amount).serializedData()
//        LndmobileOpenChannel(data, LndCallback<Lnrpc_OpenStatusUpdate, OpenStatusUpdate>(callback, map: OpenStatusUpdate.init))
        LndmobileOpenChannelSync(data, LndCallback<Lnrpc_ChannelPoint, Lnrpc_ChannelPoint>(callback) { $0 })

    }
    
    func closeChannel(channelPoint: String, callback: @escaping (Result<CloseStatusUpdate>) -> Void) {
        guard let data = try? Lnrpc_CloseChannelRequest(channelPoint: channelPoint)?.serializedData() else {
            callback(Result(error: LndError.invalidInput))
            return
        }
        LndmobileCloseChannel(data, LndCallback<Lnrpc_CloseStatusUpdate, CloseStatusUpdate>(callback, map: CloseStatusUpdate.init))
    }
    
    func sendCoins(address: String, amount: Satoshi, callback: @escaping (Result<String>) -> Void) {
        let data = try? Lnrpc_SendCoinsRequest(address: address, amount: amount).serializedData()
        LndmobileSendCoins(data, LndCallback<Lnrpc_SendCoinsResponse, String>(callback) { $0.txid })
    }
    
    func peers(callback: @escaping (Result<[Peer]>) -> Void) {
        LndmobileListPeers(nil, LndCallback<Lnrpc_ListPeersResponse, [Peer]>(callback) {
            $0.peers.compactMap { Peer(peer: $0) }
        })
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        let data = try? Lnrpc_PayReqString(payReq: paymentRequest).serializedData()
        LndmobileDecodePayReq(data, LndCallback<Lnrpc_PayReq, PaymentRequest>(callback) { PaymentRequest(payReq: $0, raw: paymentRequest) })
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Result<Data>) -> Void) {
        let data = try? Lnrpc_SendRequest(paymentRequest: paymentRequest.raw).serializedData()
        LndmobileSendPaymentSync(data, LndCallback<Lnrpc_SendResponse, Data>(callback) { $0.paymentPreimage })
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, callback: @escaping (Result<String>) -> Void) {
        let data = try? Lnrpc_Invoice(amount: amount, memo: memo).serializedData()
        LndmobileAddInvoice(data, LndCallback<Lnrpc_AddInvoiceResponse, String>(callback) { $0.paymentRequest })
    }
    
    func invoices(callback: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileListInvoices(nil, LndCallback<Lnrpc_ListInvoiceResponse, [Transaction]>(callback) {
            $0.invoices.compactMap { LightningInvoice(invoice: $0) }
        })
    }
    
    func subscribeChannelGraph(callback: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        LndmobileSubscribeChannelGraph(nil, LndCallback<Lnrpc_GraphTopologyUpdate, GraphTopologyUpdate>(callback, map: GraphTopologyUpdate.init))
    }
}
