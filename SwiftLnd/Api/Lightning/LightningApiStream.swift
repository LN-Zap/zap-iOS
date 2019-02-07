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
    
    public func routes(destination: String, amount: Satoshi, completion: @escaping (Result<[Route], LndApiError>) -> Void) {
        let data = LNDQueryRoutesRequest(destination: destination, amount: amount).data()
        LndmobileQueryRoutes(data, StreamCallback(completion, transform: LightningApiTransformation.routes))
    }
    
    public func info(completion: @escaping (Result<Info, LndApiError>) -> Void) {
        LndmobileGetInfo(nil, StreamCallback(completion, transform: LightningApiTransformation.info))
    }
    
    public func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo, LndApiError>) -> Void) {
        let data = LNDNodeInfoRequest(pubKey: pubKey).data()
        LndmobileGetNodeInfo(data, StreamCallback(completion, transform: LightningApiTransformation.nodeInfo))
    }
    
    public func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress, LndApiError>) -> Void) {
        let data = LNDNewAddressRequest(type: type).data()
        LndmobileNewAddress(data, StreamCallback(completion, transform: LightningApiTransformation.newAddress))
    }
    
    public func walletBalance(completion: @escaping (Result<Satoshi, LndApiError>) -> Void) {
        LndmobileWalletBalance(nil, StreamCallback(completion, transform: LightningApiTransformation.walletBalance))
    }
    
    public func channelBalance(completion: @escaping (Result<Satoshi, LndApiError>) -> Void) {
        LndmobileChannelBalance(nil, StreamCallback(completion, transform: LightningApiTransformation.channelBalance))
    }
    
    public func transactions(completion: @escaping (Result<[Transaction], LndApiError>) -> Void) {
        LndmobileGetTransactions(nil, StreamCallback(completion, transform: LightningApiTransformation.transactions))
    }
    
    public func subscribeTransactions(completion: @escaping (Result<Transaction, LndApiError>) -> Void) {
        LndmobileSubscribeTransactions(nil, StreamCallback(completion, transform: LightningApiTransformation.subscribeTransactions))
    }
    
    public func payments(completion: @escaping (Result<[Payment], LndApiError>) -> Void) {
        LndmobileListPayments(nil, StreamCallback(completion, transform: LightningApiTransformation.payments))
    }
    
    public func channels(completion: @escaping (Result<[Channel], LndApiError>) -> Void) {
        LndmobileListChannels(nil, StreamCallback(completion, transform: LightningApiTransformation.channels))
    }
    
    public func closedChannels(completion: @escaping (Result<[ChannelCloseSummary], LndApiError>) -> Void) {
        LndmobileClosedChannels(nil, StreamCallback(completion, transform: LightningApiTransformation.closedChannels))
    }
    
    public func pendingChannels(completion: @escaping (Result<[Channel], LndApiError>) -> Void) {
        LndmobilePendingChannels(nil, StreamCallback(completion, transform: LightningApiTransformation.pendingChannels))
    }
    
    public func connect(pubKey: String, host: String, completion: @escaping (Result<Success, LndApiError>) -> Void) {
        let data = LNDConnectPeerRequest(pubKey: pubKey, host: host).data()
        LndmobileConnectPeer(data, StreamCallback(completion, transform: LightningApiTransformation.connect))
    }
    
    public func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint, LndApiError>) -> Void) {
        let data = LNDOpenChannelRequest(pubKey: pubKey, amount: amount).data()
        LndmobileOpenChannelSync(data, StreamCallback(completion, transform: LightningApiTransformation.openChannel))
    }
    
    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate, LndApiError>) -> Void) {
        if let data = LNDCloseChannelRequest(channelPoint: channelPoint, force: force)?.data() {
            LndmobileCloseChannel(data, StreamCallback(completion, transform: LightningApiTransformation.closeChannel))
        } else {
            completion(.failure(LndApiError.invalidInput))
        }
    }
    
    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String, LndApiError>) -> Void) {
        let data = LNDSendCoinsRequest(address: address, amount: amount).data()
        LndmobileSendCoins(data, StreamCallback(completion, transform: LightningApiTransformation.sendCoins))
    }
    
    public func peers(completion: @escaping (Result<[Peer], LndApiError>) -> Void) {
        LndmobileListPeers(nil, StreamCallback(completion, transform: LightningApiTransformation.peers))
    }
    
    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest, LndApiError>) -> Void) {
        let data = LNDPayReqString(payReq: paymentRequest).data()
        LndmobileDecodePayReq(data, StreamCallback(completion, transform: LightningApiTransformation.decodePaymentRequest(paymentRequest: paymentRequest)))
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<Payment, LndApiError>) -> Void) {
        let data = LNDSendRequest(paymentRequest: paymentRequest.raw, amount: amount).data()
        LndmobileSendPaymentSync(data, StreamCallback<LNDSendResponse, Payment>(completion, transform: LightningApiTransformation.sendPayment(paymentRequest: paymentRequest, amount: amount)))
    }
    
    public func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String, LndApiError>) -> Void) {
        let data = LNDInvoice(amount: amount, memo: memo).data()
        LndmobileAddInvoice(data, StreamCallback(completion, transform: LightningApiTransformation.addInvoice))
    }
    
    public func invoices(completion: @escaping (Result<[Invoice], LndApiError>) -> Void) {
        let data = LNDListInvoiceRequest(reversed: true).data()
        LndmobileListInvoices(data, StreamCallback(completion, transform: LightningApiTransformation.invoices))
    }
    
    public func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate, LndApiError>) -> Void) {
        LndmobileSubscribeChannelGraph(nil, StreamCallback(completion, transform: LightningApiTransformation.subscribeChannelGraph))
    }
    
    public func subscribeInvoices(completion: @escaping (Result<Invoice, LndApiError>) -> Void) {
        LndmobileSubscribeInvoices(nil, StreamCallback(completion, transform: LightningApiTransformation.subscribeInvoices))
    }
}

#endif
