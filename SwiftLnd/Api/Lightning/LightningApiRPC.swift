//
//  Zap
//
//  Created by Otto Suess on 05.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc
import SwiftBTC

public final class LightningApiRPC: LightningApiProtocol {
    private let lnd: LNDLightning
    private let macaroon: String
    
    public init(configuration: RemoteRPCConfiguration) {
        let host = configuration.url.absoluteString
        lnd = LNDLightning(host: host)
        if let certificate = configuration.certificate {
            try? GRPCCall.setTLSPEMRootCerts(certificate, forHost: host)
        }
        macaroon = configuration.macaroon.hexadecimalString
    }
    
    public func canConnect(completion: @escaping (Bool) -> Void) {
        lnd.rpcToGetInfo(with: LNDGetInfoRequest()) { response, _ in
            completion(response != nil)
        }.runWithMacaroon(macaroon)
    }
    
    public func info(completion: @escaping Handler<Info>) {
        lnd.rpcToGetInfo(with: LNDGetInfoRequest(), handler: createHandler(completion, transform: LightningApiTransformation.info))
            .runWithMacaroon(macaroon)
    }
    
    public func nodeInfo(pubKey: String, completion: @escaping Handler<NodeInfo>) {
        let request = LNDNodeInfoRequest(pubKey: pubKey)
        lnd.rpcToGetNodeInfo(with: request, handler: createHandler(completion, transform: LightningApiTransformation.nodeInfo))
            .runWithMacaroon(macaroon)
    }
    
    public func newAddress(type: OnChainRequestAddressType, completion: @escaping Handler<BitcoinAddress>) {
        let request = LNDNewAddressRequest(type: type)
        lnd.rpcToNewAddress(with: request, handler: createHandler(completion, transform: LightningApiTransformation.newAddress)).runWithMacaroon(macaroon)
    }
    
    public func walletBalance(completion: @escaping Handler<Satoshi>) {
        lnd.rpcToWalletBalance(with: LNDWalletBalanceRequest(), handler: createHandler(completion, transform: LightningApiTransformation.walletBalance))
            .runWithMacaroon(macaroon)
    }
    
    public func channelBalance(completion: @escaping Handler<Satoshi>) {
        lnd.rpcToChannelBalance(with: LNDChannelBalanceRequest(), handler: createHandler(completion, transform: LightningApiTransformation.channelBalance))
            .runWithMacaroon(macaroon)
    }
    
    public func transactions(completion: @escaping Handler<[Transaction]>) {
        lnd.rpcToGetTransactions(with: LNDGetTransactionsRequest(), handler: createHandler(completion, transform: LightningApiTransformation.transactions)).runWithMacaroon(macaroon)
    }
    
    public func payments(completion: @escaping Handler<[Payment]>) {
        lnd.rpcToListPayments(with: LNDListPaymentsRequest(), handler: createHandler(completion, transform: LightningApiTransformation.payments)).runWithMacaroon(macaroon)
    }
    
    public func routes(destination: String, amount: Satoshi, completion: @escaping Handler<[Route]>) {
        let request = LNDQueryRoutesRequest(destination: destination, amount: amount)
        lnd.rpcToQueryRoutes(with: request, handler: createHandler(completion, transform: LightningApiTransformation.routes)).runWithMacaroon(macaroon)
    }
    
    public func channels(completion: @escaping Handler<[Channel]>) {
        lnd.rpcToListChannels(with: LNDListChannelsRequest(), handler: createHandler(completion, transform: LightningApiTransformation.channels)).runWithMacaroon(macaroon)
    }
    
    public func closedChannels(completion: @escaping Handler<[ChannelCloseSummary]>) {
        lnd.rpcToClosedChannels(with: LNDClosedChannelsRequest(), handler: createHandler(completion, transform: LightningApiTransformation.closedChannels)).runWithMacaroon(macaroon)
    }
    
    public func pendingChannels(completion: @escaping Handler<[Channel]>) {
        lnd.rpcToPendingChannels(with: LNDPendingChannelsRequest(), handler: createHandler(completion, transform: LightningApiTransformation.pendingChannels)).runWithMacaroon(macaroon)
    }
    
    public func connect(pubKey: String, host: String, completion: @escaping Handler<Success>) {
        let request = LNDConnectPeerRequest(pubKey: pubKey, host: host)        
        lnd.rpcToConnectPeer(with: request, handler: createHandler(completion, transform: LightningApiTransformation.connect)).runWithMacaroon(macaroon)
    }
    
    public func openChannel(pubKey: String, amount: Satoshi, completion: @escaping Handler<ChannelPoint>) {
        let request = LNDOpenChannelRequest(pubKey: pubKey, amount: amount)
        lnd.rpcToOpenChannelSync(with: request, handler: createHandler(completion, transform: LightningApiTransformation.openChannel)).runWithMacaroon(macaroon)
    }
    
    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping Handler<String>) {
        let request = LNDSendCoinsRequest(address: address, amount: amount)
        lnd.rpcToSendCoins(with: request, handler: createHandler(completion, transform: LightningApiTransformation.sendCoins)).runWithMacaroon(macaroon)
    }
    
    public func peers(completion: @escaping Handler<[Peer]>) {
        lnd.rpcToListPeers(with: LNDListPeersRequest(), handler: createHandler(completion, transform: LightningApiTransformation.peers)).runWithMacaroon(macaroon)
    }
    
    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping Handler<PaymentRequest>) {
        let request = LNDPayReqString(payReq: paymentRequest)
        lnd.rpcToDecodePayReq(withRequest: request, handler: createHandler(completion, transform: LightningApiTransformation.decodePaymentRequest(paymentRequest: paymentRequest))).runWithMacaroon(macaroon)
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping Handler<Payment>) {
        let request = LNDSendRequest(paymentRequest: paymentRequest.raw, amount: amount)
        lnd.rpcToSendPaymentSync(with: request, handler: createHandler(completion, transform: LightningApiTransformation.sendPayment(paymentRequest: paymentRequest, amount: amount))).runWithMacaroon(macaroon)
    }
    
    public func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping Handler<String>) {
        let request = LNDInvoice(amount: amount, memo: memo)
        lnd.rpcToAddInvoice(withRequest: request, handler: createHandler(completion, transform: LightningApiTransformation.addInvoice)).runWithMacaroon(macaroon)
    }
    
    public func invoices(completion: @escaping Handler<[Invoice]>) {
        let request = LNDListInvoiceRequest(reversed: true)
        lnd.rpcToListInvoices(with: request, handler: createHandler(completion, transform: LightningApiTransformation.invoices)).runWithMacaroon(macaroon)
    }
    
    public func subscribeChannelGraph(completion: @escaping Handler<GraphTopologyUpdate>) {
        lnd.rpcToSubscribeChannelGraph(withRequest: LNDGraphTopologySubscription(), eventHandler: createHandler(completion, transform: LightningApiTransformation.subscribeChannelGraph)).runWithMacaroon(macaroon)
    }
    
    public func subscribeInvoices(completion: @escaping Handler<Invoice>) {
        lnd.rpcToSubscribeInvoices(withRequest: LNDInvoiceSubscription(), eventHandler: createHandler(completion, transform: LightningApiTransformation.subscribeInvoices)).runWithMacaroon(macaroon)
    }
    
    public func subscribeTransactions(completion: @escaping Handler<Transaction>) {
        lnd.rpcToSubscribeTransactions(with: LNDGetTransactionsRequest(), eventHandler: createHandler(completion, transform: LightningApiTransformation.subscribeTransactions)).runWithMacaroon(macaroon)
    }
    
    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping Handler<CloseStatusUpdate>) {
        if let request = LNDCloseChannelRequest(channelPoint: channelPoint, force: force) {
            lnd.rpcToCloseChannel(with: request, eventHandler: createHandler(completion, transform: LightningApiTransformation.closeChannel)).runWithMacaroon(macaroon)
        } else {
            completion(.failure(LndApiError.invalidInput))
        }
    }
}
