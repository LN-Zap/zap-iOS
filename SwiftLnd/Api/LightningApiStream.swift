//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile
import LndRpc
import SwiftBTC

public final class LightningApiStream: LightningApiProtocol {
    public init() {}
    
    public func routes(destination: String, amount: Satoshi, completion: @escaping (Result<[Route]>) -> Void) {
        let data = LNDQueryRoutesRequest(destination: destination, amount: amount).data()
        LndmobileQueryRoutes(data, StreamCallback(completion, map: ApiResultMapping.routes))
    }
    
    public func info(completion: @escaping (Result<Info>) -> Void) {
        LndmobileGetInfo(nil, StreamCallback(completion, map: ApiResultMapping.info))
    }
    
    public func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo>) -> Void) {
        let data = LNDNodeInfoRequest(pubKey: pubKey).data()
        LndmobileGetNodeInfo(data, StreamCallback(completion, map: ApiResultMapping.nodeInfo))
    }
    
    public func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        let data = LNDNewAddressRequest(type: type).data()
        LndmobileNewAddress(data, StreamCallback(completion, map: ApiResultMapping.newAddress))
    }
    
    public func walletBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        LndmobileWalletBalance(nil, StreamCallback(completion, map: ApiResultMapping.walletBalance))
    }
    
    public func channelBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        LndmobileChannelBalance(nil, StreamCallback(completion, map: ApiResultMapping.channelBalance))
    }
    
    public func transactions(completion: @escaping (Result<[Transaction]>) -> Void) {
        LndmobileGetTransactions(nil, StreamCallback(completion, map: ApiResultMapping.transactions))
    }
    
    public func subscribeTransactions(completion: @escaping (Result<Transaction>) -> Void) {
        LndmobileSubscribeTransactions(nil, StreamCallback(completion, map: ApiResultMapping.subscribeTransactions))
    }
    
    public func payments(completion: @escaping (Result<[Payment]>) -> Void) {
        LndmobileListPayments(nil, StreamCallback(completion, map: ApiResultMapping.payments))
    }
    
    public func channels(completion: @escaping (Result<[Channel]>) -> Void) {
        LndmobileListChannels(nil, StreamCallback(completion, map: ApiResultMapping.channels))
    }
    
    public func closedChannels(completion: @escaping (Result<[ChannelCloseSummary]>) -> Void) {
        LndmobileClosedChannels(nil, StreamCallback(completion, map: ApiResultMapping.closedChannels))
    }
    
    public func pendingChannels(completion: @escaping (Result<[Channel]>) -> Void) {
        LndmobilePendingChannels(nil, StreamCallback(completion, map: ApiResultMapping.pendingChannels))
    }
    
    public func connect(pubKey: String, host: String, completion: @escaping (Result<Success>) -> Void) {
        let data = LNDConnectPeerRequest(pubKey: pubKey, host: host).data()
        LndmobileConnectPeer(data, StreamCallback(completion, map: ApiResultMapping.connect))
    }
    
    public func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint>) -> Void) {
        let data = LNDOpenChannelRequest(pubKey: pubKey, amount: amount).data()
        LndmobileOpenChannelSync(data, StreamCallback(completion, map: ApiResultMapping.openChannel))
    }
    
    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate>) -> Void) {
        if let data = LNDCloseChannelRequest(channelPoint: channelPoint, force: force)?.data() {
            LndmobileCloseChannel(data, StreamCallback(completion, map: ApiResultMapping.closeChannel))
        } else {
            completion(.failure(LndApiError.invalidInput))
        }
    }
    
    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String>) -> Void) {
        let data = LNDSendCoinsRequest(address: address, amount: amount).data()
        LndmobileSendCoins(data, StreamCallback(completion, map: ApiResultMapping.sendCoins))
    }
    
    public func peers(completion: @escaping (Result<[Peer]>) -> Void) {
        LndmobileListPeers(nil, StreamCallback(completion, map: ApiResultMapping.peers))
    }
    
    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        let data = LNDPayReqString(payReq: paymentRequest).data()
        LndmobileDecodePayReq(data, StreamCallback<LNDPayReq, PaymentRequest>(completion) { PaymentRequest(payReq: $0, raw: paymentRequest) })
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<Payment>) -> Void) {
        let data = LNDSendRequest(paymentRequest: paymentRequest.raw, amount: amount).data()
        LndmobileSendPaymentSync(data, StreamCallback<LNDSendResponse, Payment>(completion) { Payment(paymentRequest: paymentRequest, sendResponse: $0) })
    }
    
    public func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String>) -> Void) {
        let data = LNDInvoice(amount: amount, memo: memo).data()
        LndmobileAddInvoice(data, StreamCallback(completion, map: ApiResultMapping.addInvoice))
    }
    
    public func invoices(completion: @escaping (Result<[Invoice]>) -> Void) {
        let data = LNDListInvoiceRequest(reversed: true).data()
        LndmobileListInvoices(data, StreamCallback(completion, map: ApiResultMapping.invoices))
    }
    
    public func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        LndmobileSubscribeChannelGraph(nil, StreamCallback(completion, map: ApiResultMapping.subscribeChannelGraph))
    }
    
    public func subscribeInvoices(completion: @escaping (Result<Invoice>) -> Void) {
        LndmobileSubscribeInvoices(nil, StreamCallback(completion, map: ApiResultMapping.subscribeInvoices))
    }
}

#endif
