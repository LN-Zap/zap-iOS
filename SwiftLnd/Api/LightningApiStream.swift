//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !REMOTEONLY

import BTCUtil
import Foundation
import Lndmobile

public final class LightningApiStream: LightningApiProtocol {
    public init() {}
    
    public func info(completion: @escaping (Result<Info>) -> Void) {
        LndmobileGetInfo(nil, StreamCallback<Lnrpc_GetInfoResponse, Info>(completion, map: Info.init))
    }
    
    public func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo>) -> Void) {
        let data = try? Lnrpc_NodeInfoRequest(pubKey: pubKey).serializedData()
        LndmobileGetNodeInfo(data, StreamCallback<Lnrpc_NodeInfo, NodeInfo>(completion, map: NodeInfo.init))
    }
    
    public func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        let data = try? Lnrpc_NewAddressRequest(type: type).serializedData()
        LndmobileNewAddress(data, StreamCallback<Lnrpc_NewAddressResponse, BitcoinAddress>(completion) { BitcoinAddress(string: $0.address) })
    }
    
    public func walletBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        LndmobileWalletBalance(nil, StreamCallback<Lnrpc_WalletBalanceResponse, Satoshi>(completion) { Satoshi($0.totalBalance) })
    }
    
    public func channelBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        LndmobileChannelBalance(nil, StreamCallback<Lnrpc_ChannelBalanceResponse, Satoshi>(completion) { Satoshi($0.balance) })
    }
    
    public func transactions(completion: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileGetTransactions(nil, StreamCallback<Lnrpc_TransactionDetails, [Transaction]>(completion) {
            $0.transactions.compactMap(Transaction.init)
        })
    }
    
    public func subscribeTransactions(completion: @escaping (Result<Transaction>) -> Void) {
        LndmobileSubscribeTransactions(nil, StreamCallback<Lnrpc_Transaction, Transaction>(completion, map: Transaction.init))
    }
    
    public func payments(completion: @escaping (Result<[Payment]>) -> Void) {
        LndmobileListPayments(nil, StreamCallback<Lnrpc_ListPaymentsResponse, [Payment]>(completion) {
            $0.payments.compactMap(Payment.init)
        })
    }
    
    public func channels(completion: @escaping (Result<[Channel]>) -> Void) {
        LndmobileListChannels(nil, StreamCallback<Lnrpc_ListChannelsResponse, [Channel]>(completion) {
            $0.channels.compactMap { $0.channelModel }
        })
    }
    
    public func closedChannels(completion: @escaping (Result<[ChannelCloseSummary]>) -> Void) {
        // TODO
    }
    
    public func pendingChannels(completion: @escaping (Result<[Channel]>) -> Void) {
        LndmobilePendingChannels(nil, StreamCallback<Lnrpc_PendingChannelsResponse, [Channel]>(completion) {
            let pendingOpenChannels: [Channel] = $0.pendingOpenChannels.compactMap { $0.channelModel }
            let pendingClosingChannels: [Channel] = $0.pendingClosingChannels.compactMap { $0.channelModel }
            let pendingForceClosingChannels: [Channel] = $0.pendingForceClosingChannels.compactMap { $0.channelModel }
            return pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels
        })
    }
    
    public func connect(pubKey: String, host: String, completion: @escaping (Result<Success>) -> Void) {
        let data = try? Lnrpc_ConnectPeerRequest(pubKey: pubKey, host: host).serializedData()
        LndmobileConnectPeer(data, StreamCallback<Lnrpc_ConnectPeerResponse, Success>(completion) { _ in Success() })
    }
    
    public func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint>) -> Void) {
        let data = try? Lnrpc_OpenChannelRequest(pubKey: pubKey, amount: amount).serializedData()
        LndmobileOpenChannelSync(data, StreamCallback<Lnrpc_ChannelPoint, ChannelPoint>(completion) { ChannelPoint(channelPoint: $0) })
    }
    
    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate>) -> Void) {
        guard let data = try? Lnrpc_CloseChannelRequest(channelPoint: channelPoint, force: force)?.serializedData() else {
            completion(.failure(LndApiError.invalidInput))
            return
        }
        LndmobileCloseChannel(data, StreamCallback<Lnrpc_CloseStatusUpdate, CloseStatusUpdate>(completion, map: CloseStatusUpdate.init))
    }
    
    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String>) -> Void) {
        let data = try? Lnrpc_SendCoinsRequest(address: address, amount: amount).serializedData()
        LndmobileSendCoins(data, StreamCallback<Lnrpc_SendCoinsResponse, String>(completion) {
            $0.txid
        })
    }
    
    public func peers(completion: @escaping (Result<[Peer]>) -> Void) {
        LndmobileListPeers(nil, StreamCallback<Lnrpc_ListPeersResponse, [Peer]>(completion) {
            $0.peers.compactMap { Peer(peer: $0) }
        })
    }
    
    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        let data = try? Lnrpc_PayReqString(payReq: paymentRequest).serializedData()
        LndmobileDecodePayReq(data, StreamCallback<Lnrpc_PayReq, PaymentRequest>(completion) { PaymentRequest(payReq: $0, raw: paymentRequest) })
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<Payment>) -> Void) {
        let data = try? Lnrpc_SendRequest(paymentRequest: paymentRequest.raw, amount: amount).serializedData()
        LndmobileSendPaymentSync(data, StreamCallback<Lnrpc_SendResponse, Payment>(completion) { Payment(paymentRequest: paymentRequest, sendResponse: $0) })
    }
    
    public func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String>) -> Void) {
        let data = try? Lnrpc_Invoice(amount: amount, memo: memo).serializedData()
        LndmobileAddInvoice(data, StreamCallback<Lnrpc_AddInvoiceResponse, String>(completion) { $0.paymentRequest })
    }
    
    public func invoices(completion: @escaping (Result<[Invoice]>) -> Void) {
        LndmobileListInvoices(nil, StreamCallback<Lnrpc_ListInvoiceResponse, [Invoice]>(completion) {
            $0.invoices.compactMap(Invoice.init)
        })
    }
    
    public func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        LndmobileSubscribeChannelGraph(nil, StreamCallback<Lnrpc_GraphTopologyUpdate, GraphTopologyUpdate>(completion, map: GraphTopologyUpdate.init))
    }
    
    public func subscribeInvoices(completion: @escaping (Result<Invoice>) -> Void) {
        LndmobileSubscribeInvoices(nil, StreamCallback<Lnrpc_Invoice, Invoice>(completion, map: Invoice.init))
    }
}

#endif
