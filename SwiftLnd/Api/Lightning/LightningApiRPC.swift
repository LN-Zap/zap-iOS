//
//  Zap
//
//  Created by Otto Suess on 05.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc
import SwiftBTC

extension GRPCProtoCall {
    func runWithMacaroon(_ macaroon: String) {
        requestHeaders["macaroon"] = macaroon
        start()
    }
}

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
    
    public func info(completion: @escaping (Result<Info, LndApiError>) -> Void) {
        lnd.rpcToGetInfo(with: LNDGetInfoRequest(), handler: createHandler(completion, map: LightningApiTransformations.info))
            .runWithMacaroon(macaroon)
    }
    
    public func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo, LndApiError>) -> Void) {
        let request = LNDNodeInfoRequest(pubKey: pubKey)
        lnd.rpcToGetNodeInfo(with: request, handler: createHandler(completion, map: LightningApiTransformations.nodeInfo))
            .runWithMacaroon(macaroon)
    }
    
    public func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress, LndApiError>) -> Void) {
        let request = LNDNewAddressRequest(type: type)
        lnd.rpcToNewAddress(with: request, handler: createHandler(completion, map: LightningApiTransformations.newAddress)).runWithMacaroon(macaroon)
    }
    
    public func walletBalance(completion: @escaping (Result<Satoshi, LndApiError>) -> Void) {
        lnd.rpcToWalletBalance(with: LNDWalletBalanceRequest(), handler: createHandler(completion, map: LightningApiTransformations.walletBalance))
            .runWithMacaroon(macaroon)
    }
    
    public func channelBalance(completion: @escaping (Result<Satoshi, LndApiError>) -> Void) {
        lnd.rpcToChannelBalance(with: LNDChannelBalanceRequest(), handler: createHandler(completion, map: LightningApiTransformations.channelBalance))
            .runWithMacaroon(macaroon)
    }
    
    public func transactions(completion: @escaping (Result<[Transaction], LndApiError>) -> Void) {
        lnd.rpcToGetTransactions(with: LNDGetTransactionsRequest(), handler: createHandler(completion, map: LightningApiTransformations.transactions)).runWithMacaroon(macaroon)
    }
    
    public func payments(completion: @escaping (Result<[Payment], LndApiError>) -> Void) {
        lnd.rpcToListPayments(with: LNDListPaymentsRequest(), handler: createHandler(completion, map: LightningApiTransformations.payments)).runWithMacaroon(macaroon)
    }
    
    public func routes(destination: String, amount: Satoshi, completion: @escaping (Result<[Route], LndApiError>) -> Void) {
        let request = LNDQueryRoutesRequest(destination: destination, amount: amount)
        lnd.rpcToQueryRoutes(with: request, handler: createHandler(completion, map: LightningApiTransformations.routes)).runWithMacaroon(macaroon)
    }
    
    public func channels(completion: @escaping (Result<[Channel], LndApiError>) -> Void) {
        lnd.rpcToListChannels(with: LNDListChannelsRequest(), handler: createHandler(completion, map: LightningApiTransformations.channels)).runWithMacaroon(macaroon)
    }
    
    public func closedChannels(completion: @escaping (Result<[ChannelCloseSummary], LndApiError>) -> Void) {
        lnd.rpcToClosedChannels(with: LNDClosedChannelsRequest(), handler: createHandler(completion, map: LightningApiTransformations.closedChannels)).runWithMacaroon(macaroon)
    }
    
    public func pendingChannels(completion: @escaping (Result<[Channel], LndApiError>) -> Void) {
        lnd.rpcToPendingChannels(with: LNDPendingChannelsRequest(), handler: createHandler(completion, map: LightningApiTransformations.pendingChannels)).runWithMacaroon(macaroon)
    }
    
    public func connect(pubKey: String, host: String, completion: @escaping (Result<Success, LndApiError>) -> Void) {
        let request = LNDConnectPeerRequest(pubKey: pubKey, host: host)        
        lnd.rpcToConnectPeer(with: request, handler: createHandler(completion, map: LightningApiTransformations.connect)).runWithMacaroon(macaroon)
    }
    
    public func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint, LndApiError>) -> Void) {
        let request = LNDOpenChannelRequest(pubKey: pubKey, amount: amount)
        lnd.rpcToOpenChannelSync(with: request, handler: createHandler(completion, map: LightningApiTransformations.openChannel)).runWithMacaroon(macaroon)
    }
    
    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String, LndApiError>) -> Void) {
        let request = LNDSendCoinsRequest(address: address, amount: amount)
        lnd.rpcToSendCoins(with: request, handler: createHandler(completion, map: LightningApiTransformations.sendCoins)).runWithMacaroon(macaroon)
    }
    
    public func peers(completion: @escaping (Result<[Peer], LndApiError>) -> Void) {
        lnd.rpcToListPeers(with: LNDListPeersRequest(), handler: createHandler(completion, map: LightningApiTransformations.peers)).runWithMacaroon(macaroon)
    }
    
    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest, LndApiError>) -> Void) {
        let request = LNDPayReqString(payReq: paymentRequest)
        lnd.rpcToDecodePayReq(withRequest: request, handler: createHandler(completion, map: LightningApiTransformations.decodePaymentRequest(paymentRequest: paymentRequest))).runWithMacaroon(macaroon)
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<Payment, LndApiError>) -> Void) {
        let request = LNDSendRequest(paymentRequest: paymentRequest.raw, amount: amount)
        lnd.rpcToSendPaymentSync(with: request, handler: createHandler(completion, map: LightningApiTransformations.sendPayment(paymentRequest: paymentRequest, amount: amount))).runWithMacaroon(macaroon)
    }
    
    public func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String, LndApiError>) -> Void) {
        let request = LNDInvoice(amount: amount, memo: memo)
        lnd.rpcToAddInvoice(withRequest: request, handler: createHandler(completion, map: LightningApiTransformations.addInvoice)).runWithMacaroon(macaroon)
    }
    
    public func invoices(completion: @escaping (Result<[Invoice], LndApiError>) -> Void) {
        let request = LNDListInvoiceRequest(reversed: true)
        lnd.rpcToListInvoices(with: request, handler: createHandler(completion, map: LightningApiTransformations.invoices)).runWithMacaroon(macaroon)
    }
    
    public func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate, LndApiError>) -> Void) {
        lnd.rpcToSubscribeChannelGraph(withRequest: LNDGraphTopologySubscription(), eventHandler: createHandler(completion, map: LightningApiTransformations.subscribeChannelGraph)).runWithMacaroon(macaroon)
    }
    
    public func subscribeInvoices(completion: @escaping (Result<Invoice, LndApiError>) -> Void) {
        lnd.rpcToSubscribeInvoices(withRequest: LNDInvoiceSubscription(), eventHandler: createHandler(completion, map: LightningApiTransformations.subscribeInvoices)).runWithMacaroon(macaroon)
    }
    
    public func subscribeTransactions(completion: @escaping (Result<Transaction, LndApiError>) -> Void) {
        lnd.rpcToSubscribeTransactions(with: LNDGetTransactionsRequest(), eventHandler: createHandler(completion, map: LightningApiTransformations.subscribeTransactions)).runWithMacaroon(macaroon)
    }
    
    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate, LndApiError>) -> Void) {
        if let request = LNDCloseChannelRequest(channelPoint: channelPoint, force: force) {
            lnd.rpcToCloseChannel(with: request, eventHandler: createHandler(completion, map: LightningApiTransformations.closeChannel)).runWithMacaroon(macaroon)
        } else {
            completion(.failure(LndApiError.invalidInput))
        }
    }
}
