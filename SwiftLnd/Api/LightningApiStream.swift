//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile
import SwiftBTC

public final class LightningApiStream: LightningApiProtocol {
    public init() {}
    
    public func info(completion: @escaping (Result<Info>) -> Void) {
        LndmobileGetInfo(nil, StreamCallback<LNDGetInfoResponse, Info>(completion, map: Info.init))
    }
    
    public func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo>) -> Void) {
        let data = try? LNDNodeInfoRequest(pubKey: pubKey).serializedData()
        LndmobileGetNodeInfo(data, StreamCallback<LNDNodeInfo, NodeInfo>(completion, map: NodeInfo.init))
    }
    
    public func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        let data = try? LNDNewAddressRequest(type: type).serializedData()
        LndmobileNewAddress(data, StreamCallback<LNDNewAddressResponse, BitcoinAddress>(completion) { BitcoinAddress(string: $0.address) })
    }
    
    public func walletBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        LndmobileWalletBalance(nil, StreamCallback<LNDWalletBalanceResponse, Satoshi>(completion) { Satoshi($0.totalBalance) })
    }
    
    public func channelBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        LndmobileChannelBalance(nil, StreamCallback<LNDChannelBalanceResponse, Satoshi>(completion) { Satoshi($0.balance) })
    }
    
    public func transactions(completion: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileGetTransactions(nil, StreamCallback<LNDTransactionDetails, [Transaction]>(completion) {
            $0.transactions.compactMap(Transaction.init)
        })
    }
    
    public func subscribeTransactions(completion: @escaping (Result<Transaction>) -> Void) {
        LndmobileSubscribeTransactions(nil, StreamCallback<LNDTransaction, Transaction>(completion, map: Transaction.init))
    }
    
    public func payments(completion: @escaping (Result<[Payment]>) -> Void) {
        LndmobileListPayments(nil, StreamCallback<LNDListPaymentsResponse, [Payment]>(completion) {
            $0.payments.compactMap(Payment.init)
        })
    }
    
    public func channels(completion: @escaping (Result<[Channel]>) -> Void) {
        LndmobileListChannels(nil, StreamCallback<LNDListChannelsResponse, [Channel]>(completion) {
            $0.channels.compactMap { $0.channelModel }
        })
    }
    
    public func closedChannels(completion: @escaping (Result<[ChannelCloseSummary]>) -> Void) {
        // TODO
    }
    
    public func pendingChannels(completion: @escaping (Result<[Channel]>) -> Void) {
        LndmobilePendingChannels(nil, StreamCallback<LNDPendingChannelsResponse, [Channel]>(completion) {
            $0.channels
        })
    }
    
    public func connect(pubKey: String, host: String, completion: @escaping (Result<Success>) -> Void) {
        let data = try? LNDConnectPeerRequest(pubKey: pubKey, host: host).serializedData()
        LndmobileConnectPeer(data, StreamCallback<LNDConnectPeerResponse, Success>(completion) { _ in Success() })
    }
    
    public func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint>) -> Void) {
        let data = try? LNDOpenChannelRequest(pubKey: pubKey, amount: amount).serializedData()
        LndmobileOpenChannelSync(data, StreamCallback<LNDChannelPoint, ChannelPoint>(completion) { ChannelPoint(channelPoint: $0) })
    }
    
    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate>) -> Void) {
        guard let data = try? LNDCloseChannelRequest(channelPoint: channelPoint, force: force)?.serializedData() else {
            completion(.failure(LndApiError.invalidInput))
            return
        }
        LndmobileCloseChannel(data, StreamCallback<LNDCloseStatusUpdate, CloseStatusUpdate>(completion, map: CloseStatusUpdate.init))
    }
    
    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String>) -> Void) {
        let data = try? LNDSendCoinsRequest(address: address, amount: amount).serializedData()
        LndmobileSendCoins(data, StreamCallback<LNDSendCoinsResponse, String>(completion) {
            $0.txid
        })
    }
    
    public func peers(completion: @escaping (Result<[Peer]>) -> Void) {
        LndmobileListPeers(nil, StreamCallback<LNDListPeersResponse, [Peer]>(completion) {
            $0.peers.compactMap { Peer(peer: $0) }
        })
    }
    
    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        let data = try? LNDPayReqString(payReq: paymentRequest).serializedData()
        LndmobileDecodePayReq(data, StreamCallback<LNDPayReq, PaymentRequest>(completion) { PaymentRequest(payReq: $0, raw: paymentRequest) })
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<Payment>) -> Void) {
        let data = try? LNDSendRequest(paymentRequest: paymentRequest.raw, amount: amount).serializedData()
        LndmobileSendPaymentSync(data, StreamCallback<LNDSendResponse, Payment>(completion) { Payment(paymentRequest: paymentRequest, sendResponse: $0) })
    }
    
    public func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String>) -> Void) {
        let data = try? LNDInvoice(amount: amount, memo: memo).serializedData()
        LndmobileAddInvoice(data, StreamCallback<LNDAddInvoiceResponse, String>(completion) { $0.paymentRequest })
    }
    
    public func invoices(completion: @escaping (Result<[Invoice]>) -> Void) {
        let request = LNDListInvoiceRequest()
        request.reversed = true
        let data = try? request.serializedData()
        LndmobileListInvoices(nil, StreamCallback<LNDListInvoiceResponse, [Invoice]>(completion) {
            $0.invoices.compactMap(Invoice.init)
        })
    }
    
    public func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        LndmobileSubscribeChannelGraph(nil, StreamCallback<LNDGraphTopologyUpdate, GraphTopologyUpdate>(completion, map: GraphTopologyUpdate.init))
    }
    
    public func subscribeInvoices(completion: @escaping (Result<Invoice>) -> Void) {
        LndmobileSubscribeInvoices(nil, StreamCallback<LNDInvoice, Invoice>(completion, map: Invoice.init))
    }
}

#endif
