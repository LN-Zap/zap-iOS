//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !LOCALONLY

import BTCUtil
import Foundation
import Lndmobile

final class LightningApiStream: LightningApiProtocol {
    func info(completion: @escaping (Result<Info>) -> Void) {
        LndmobileGetInfo(nil, StreamCallback<Lnrpc_GetInfoResponse, Info>(completion, map: Info.init))
    }
    
    func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo>) -> Void) {
        let data = try? Lnrpc_NodeInfoRequest(pubKey: pubKey).serializedData()
        LndmobileGetNodeInfo(data, StreamCallback<Lnrpc_NodeInfo, NodeInfo>(completion, map: NodeInfo.init))
    }
    
    func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        let data = try? Lnrpc_NewAddressRequest(type: type).serializedData()
        LndmobileNewAddress(data, StreamCallback<Lnrpc_NewAddressResponse, BitcoinAddress>(completion) { BitcoinAddress(string: $0.address) })
    }
    
    func walletBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        LndmobileWalletBalance(nil, StreamCallback<Lnrpc_WalletBalanceResponse, Satoshi>(completion) { Satoshi($0.totalBalance) })
    }
    
    func channelBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        LndmobileChannelBalance(nil, StreamCallback<Lnrpc_ChannelBalanceResponse, Satoshi>(completion) { Satoshi($0.balance) })
    }
    
    func transactions(completion: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileGetTransactions(nil, StreamCallback<Lnrpc_TransactionDetails, [Transaction]>(completion) {
            $0.transactions.compactMap { OnChainConfirmedTransaction(transaction: $0) }
        })
    }
    
    func subscribeTransactions(completion: @escaping (Result<Transaction>) -> Void) {
        LndmobileSubscribeTransactions(nil, StreamCallback<Lnrpc_Transaction, Transaction>(completion, map: OnChainConfirmedTransaction.init))
    }
    
    func payments(completion: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileListPayments(nil, StreamCallback<Lnrpc_ListPaymentsResponse, [Transaction]>(completion) {
            $0.payments.compactMap { LightningPayment(payment: $0) }
        })
    }
    
    func channels(completion: @escaping (Result<[Channel]>) -> Void) {
        LndmobileListChannels(nil, StreamCallback<Lnrpc_ListChannelsResponse, [Channel]>(completion) {
            $0.channels.compactMap { $0.channelModel }
        })
    }
    
    func closedChannels(completion: @escaping (Result<[ChannelCloseSummary]>) -> Void) {
        // TODO
    }
    
    func pendingChannels(completion: @escaping (Result<[Channel]>) -> Void) {
        LndmobilePendingChannels(nil, StreamCallback<Lnrpc_PendingChannelsResponse, [Channel]>(completion) {
            let pendingOpenChannels: [Channel] = $0.pendingOpenChannels.compactMap { $0.channelModel }
            let pendingClosingChannels: [Channel] = $0.pendingClosingChannels.compactMap { $0.channelModel }
            let pendingForceClosingChannels: [Channel] = $0.pendingForceClosingChannels.compactMap { $0.channelModel }
            return pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels
        })
    }
    
    func connect(pubKey: String, host: String, completion: @escaping (Result<Success>) -> Void) {
        let data = try? Lnrpc_ConnectPeerRequest(pubKey: pubKey, host: host).serializedData()
        LndmobileConnectPeer(data, StreamCallback<Lnrpc_ConnectPeerResponse, Success>(completion) { _ in Success() })
    }
    
    func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint>) -> Void) {
        let data = try? Lnrpc_OpenChannelRequest(pubKey: pubKey, amount: amount).serializedData()
        LndmobileOpenChannelSync(data, StreamCallback<Lnrpc_ChannelPoint, ChannelPoint>(completion) { ChannelPoint(channelPoint: $0) })
    }
    
    func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate>) -> Void) {
        guard let data = try? Lnrpc_CloseChannelRequest(channelPoint: channelPoint, force: force)?.serializedData() else {
            completion(.failure(LndApiError.invalidInput))
            return
        }
        LndmobileCloseChannel(data, StreamCallback<Lnrpc_CloseStatusUpdate, CloseStatusUpdate>(completion, map: CloseStatusUpdate.init))
    }
    
    func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<OnChainUnconfirmedTransaction>) -> Void) {
        let data = try? Lnrpc_SendCoinsRequest(address: address, amount: amount).serializedData()
        LndmobileSendCoins(data, StreamCallback<Lnrpc_SendCoinsResponse, OnChainUnconfirmedTransaction>(completion) {
            OnChainUnconfirmedTransaction(id: $0.txid, amount: -amount, date: Date(), destinationAddresses: [address])
        })
    }
    
    func peers(completion: @escaping (Result<[Peer]>) -> Void) {
        LndmobileListPeers(nil, StreamCallback<Lnrpc_ListPeersResponse, [Peer]>(completion) {
            $0.peers.compactMap { Peer(peer: $0) }
        })
    }
    
    func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        let data = try? Lnrpc_PayReqString(payReq: paymentRequest).serializedData()
        LndmobileDecodePayReq(data, StreamCallback<Lnrpc_PayReq, PaymentRequest>(completion) { PaymentRequest(payReq: $0, raw: paymentRequest) })
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<LightningPayment>) -> Void) {
        let data = try? Lnrpc_SendRequest(paymentRequest: paymentRequest.raw, amount: amount).serializedData()
        LndmobileSendPaymentSync(data, StreamCallback<Lnrpc_SendResponse, LightningPayment>(completion) { LightningPayment(paymentRequest: paymentRequest, sendResponse: $0) })
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String>) -> Void) {
        let data = try? Lnrpc_Invoice(amount: amount, memo: memo).serializedData()
        LndmobileAddInvoice(data, StreamCallback<Lnrpc_AddInvoiceResponse, String>(completion) { $0.paymentRequest })
    }
    
    func invoices(completion: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileListInvoices(nil, StreamCallback<Lnrpc_ListInvoiceResponse, [Transaction]>(completion) {
            $0.invoices.compactMap { LightningInvoice(invoice: $0) }
        })
    }
    
    func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        LndmobileSubscribeChannelGraph(nil, StreamCallback<Lnrpc_GraphTopologyUpdate, GraphTopologyUpdate>(completion, map: GraphTopologyUpdate.init))
    }
    
    func subscribeInvoices(completion: @escaping (Result<Transaction>) -> Void) {
        LndmobileSubscribeInvoices(nil, StreamCallback<Lnrpc_Invoice, Transaction>(completion) {
            LightningInvoice(invoice: $0)
        })
    }
}

#endif
