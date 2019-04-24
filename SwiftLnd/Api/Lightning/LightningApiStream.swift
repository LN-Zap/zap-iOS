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

    public func routes(destination: String, amount: Satoshi, completion: @escaping Handler<[Route]>) {
        let data = LNDQueryRoutesRequest(destination: destination, amount: amount).data()
        LndmobileQueryRoutes(data, StreamCallback(completion, transform: LightningApiTransformation.routes))
    }

    public func info(completion: @escaping Handler<Info>) {
        LndmobileGetInfo(nil, StreamCallback(completion, transform: LightningApiTransformation.info))
    }

    public func nodeInfo(pubKey: String, completion: @escaping Handler<NodeInfo>) {
        let data = LNDNodeInfoRequest(pubKey: pubKey).data()
        LndmobileGetNodeInfo(data, StreamCallback(completion, transform: LightningApiTransformation.nodeInfo))
    }

    public func newAddress(type: OnChainRequestAddressType, completion: @escaping Handler<BitcoinAddress>) {
        let data = LNDNewAddressRequest(type: type).data()
        LndmobileNewAddress(data, StreamCallback(completion, transform: LightningApiTransformation.newAddress))
    }

    public func walletBalance(completion: @escaping Handler<WalletBalance>) {
        LndmobileWalletBalance(nil, StreamCallback(completion, transform: LightningApiTransformation.walletBalance))
    }

    public func channelBalance(completion: @escaping Handler<ChannelBalance>) {
        LndmobileChannelBalance(nil, StreamCallback(completion, transform: LightningApiTransformation.channelBalance))
    }

    public func transactions(completion: @escaping Handler<[Transaction]>) {
        LndmobileGetTransactions(nil, StreamCallback(completion, transform: LightningApiTransformation.transactions))
    }

    public func subscribeTransactions(completion: @escaping Handler<Transaction>) {
        LndmobileSubscribeTransactions(nil, StreamCallback(completion, transform: LightningApiTransformation.subscribeTransactions))
    }

    public func payments(completion: @escaping Handler<[Payment]>) {
        LndmobileListPayments(nil, StreamCallback(completion, transform: LightningApiTransformation.payments))
    }

    public func channels(completion: @escaping Handler<[Channel]>) {
        LndmobileListChannels(nil, StreamCallback(completion, transform: LightningApiTransformation.channels))
    }

    public func closedChannels(completion: @escaping Handler<[ChannelCloseSummary]>) {
        LndmobileClosedChannels(nil, StreamCallback(completion, transform: LightningApiTransformation.closedChannels))
    }

    public func pendingChannels(completion: @escaping Handler<[Channel]>) {
        LndmobilePendingChannels(nil, StreamCallback(completion, transform: LightningApiTransformation.pendingChannels))
    }

    public func connect(pubKey: String, host: String, completion: @escaping Handler<Success>) {
        let data = LNDConnectPeerRequest(pubKey: pubKey, host: host).data()
        LndmobileConnectPeer(data, StreamCallback(completion, transform: LightningApiTransformation.connect))
    }

    public func openChannel(pubKey: String, amount: Satoshi, completion: @escaping Handler<ChannelPoint>) {
        let data = LNDOpenChannelRequest(pubKey: pubKey, amount: amount).data()
        LndmobileOpenChannelSync(data, StreamCallback(completion, transform: LightningApiTransformation.openChannel))
    }

    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping Handler<CloseStatusUpdate>) {
        if let data = LNDCloseChannelRequest(channelPoint: channelPoint, force: force)?.data() {
            LndmobileCloseChannel(data, StreamCallback(completion, transform: LightningApiTransformation.closeChannel))
        } else {
            completion(.failure(LndApiError.invalidInput))
        }
    }

    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping Handler<String>) {
        let data = LNDSendCoinsRequest(address: address, amount: amount).data()
        LndmobileSendCoins(data, StreamCallback(completion, transform: LightningApiTransformation.sendCoins))
    }

    public func peers(completion: @escaping Handler<[Peer]>) {
        LndmobileListPeers(nil, StreamCallback(completion, transform: LightningApiTransformation.peers))
    }

    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping Handler<PaymentRequest>) {
        let data = LNDPayReqString(payReq: paymentRequest).data()
        LndmobileDecodePayReq(data, StreamCallback(completion, transform: LightningApiTransformation.decodePaymentRequest(paymentRequest: paymentRequest)))
    }

    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping Handler<Payment>) {
        let data = LNDSendRequest(paymentRequest: paymentRequest.raw, amount: amount).data()
        LndmobileSendPaymentSync(data, StreamCallback<LNDSendResponse, Payment>(completion, transform: LightningApiTransformation.sendPayment(paymentRequest: paymentRequest, amount: amount)))
    }

    public func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping Handler<String>) {
        let data = LNDInvoice(amount: amount, memo: memo).data()
        LndmobileAddInvoice(data, StreamCallback(completion, transform: LightningApiTransformation.addInvoice))
    }

    public func invoices(completion: @escaping Handler<[Invoice]>) {
        let data = LNDListInvoiceRequest(reversed: true).data()
        LndmobileListInvoices(data, StreamCallback(completion, transform: LightningApiTransformation.invoices))
    }

    public func subscribeChannelGraph(completion: @escaping Handler<GraphTopologyUpdate>) {
        LndmobileSubscribeChannelGraph(nil, StreamCallback(completion, transform: LightningApiTransformation.subscribeChannelGraph))
    }

    public func subscribeInvoices(completion: @escaping Handler<Invoice>) {
        LndmobileSubscribeInvoices(nil, StreamCallback(completion, transform: LightningApiTransformation.subscribeInvoices))
    }

    public func subscribeChannelEvents(completion: @escaping Handler<ChannelEventUpdate>) {
        LndmobileSubscribeChannelEvents(nil, StreamCallback(completion, transform: LightningApiTransformation.subscribeChannelEvents))
    }
}

#endif
