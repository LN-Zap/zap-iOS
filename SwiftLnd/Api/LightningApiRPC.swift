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
    
    public func info(completion: @escaping (Result<Info>) -> Void) {
        lnd.rpcToGetInfo(with: LNDGetInfoRequest(), handler: result(completion, map: { Info(getInfoResponse: $0) }))
            .runWithMacaroon(macaroon)
    }
    
    public func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo>) -> Void) {
        let request = LNDNodeInfoRequest(pubKey: pubKey)
        lnd.rpcToGetNodeInfo(with: request, handler: result(completion, map: { NodeInfo(nodeInfo: $0) }))
            .runWithMacaroon(macaroon)
    }
    
    public func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        let request = LNDNewAddressRequest(type: type)
        lnd.rpcToNewAddress(with: request, handler: result(completion, map: {
            BitcoinAddress(string: $0.address)
        })).runWithMacaroon(macaroon)
    }
    
    public func walletBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        lnd.rpcToWalletBalance(with: LNDWalletBalanceRequest(), handler: result(completion, map: { Satoshi($0.totalBalance) }))
            .runWithMacaroon(macaroon)
    }
    
    public func channelBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        lnd.rpcToChannelBalance(with: LNDChannelBalanceRequest(), handler: result(completion, map: { Satoshi($0.balance) }))
            .runWithMacaroon(macaroon)
    }
    
    public func transactions(completion: @escaping (Result<[Transaction]>) -> Void) {
        lnd.rpcToGetTransactions(with: LNDGetTransactionsRequest(), handler: result(completion, map: {
            $0.transactionsArray.compactMap {
                guard let transaction = $0 as? LNDTransaction else { return nil }
                return Transaction(transaction: transaction)
            }
        })).runWithMacaroon(macaroon)
    }
    
    public func payments(completion: @escaping (Result<[Payment]>) -> Void) {
        lnd.rpcToListPayments(with: LNDListPaymentsRequest(), handler: result(completion, map: {
            $0.paymentsArray.compactMap {
                guard let payment = $0 as? LNDPayment else { return nil }
                return Payment(payment: payment)
            }
        })).runWithMacaroon(macaroon)
    }
    
    public func routes(destination: String, amount: Satoshi, completion: @escaping (Result<[Route]>) -> Void) {
        let request = LNDQueryRoutesRequest(destination: destination, amount: amount)
        lnd.rpcToQueryRoutes(with: request, handler: result(completion, map: {
            $0.routesArray.compactMap {
                guard let route = $0 as? LNDRoute else { return nil }
                return Route(route: route)
            }
        })).runWithMacaroon(macaroon)
    }
    
    public func channels(completion: @escaping (Result<[Channel]>) -> Void) {
        lnd.rpcToListChannels(with: LNDListChannelsRequest(), handler: result(completion, map: {
            $0.channelsArray.compactMap { ($0 as? LNDChannel)?.channelModel }
        })).runWithMacaroon(macaroon)
    }
    
    public func closedChannels(completion: @escaping (Result<[ChannelCloseSummary]>) -> Void) {
        lnd.rpcToClosedChannels(with: LNDClosedChannelsRequest(), handler: result(completion, map: {
            $0.channelsArray.compactMap {
                guard let channelCloseSummary = $0 as? LNDChannelCloseSummary else { return nil }
                return ChannelCloseSummary(channelCloseSummary: channelCloseSummary)
            }
        })).runWithMacaroon(macaroon)
    }
    
    public func pendingChannels(completion: @escaping (Result<[Channel]>) -> Void) {
        lnd.rpcToPendingChannels(with: LNDPendingChannelsRequest(), handler: result(completion, map: {
            $0.channels
        })).runWithMacaroon(macaroon)
    }
    
    public func connect(pubKey: String, host: String, completion: @escaping (Result<Success>) -> Void) {
        let request = LNDConnectPeerRequest(pubKey: pubKey, host: host)        
        lnd.rpcToConnectPeer(with: request, handler: result(completion, map: { _ in Success() }))
            .runWithMacaroon(macaroon)
    }
    
    public func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint>) -> Void) {
        let request = LNDOpenChannelRequest(pubKey: pubKey, amount: amount)
        lnd.rpcToOpenChannelSync(with: request, handler: result(completion, map: { ChannelPoint(channelPoint: $0) }))
            .runWithMacaroon(macaroon)
    }
    
    public func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String>) -> Void) {
        let request = LNDSendCoinsRequest(address: address, amount: amount)
        lnd.rpcToSendCoins(with: request, handler: result(completion, map: { $0.txid }))
            .runWithMacaroon(macaroon)
    }
    
    public func peers(completion: @escaping (Result<[Peer]>) -> Void) {
        lnd.rpcToListPeers(with: LNDListPeersRequest(), handler: result(completion, map: {
            $0.peersArray.compactMap {
                guard let peer = $0 as? LNDPeer else { return nil }
                return Peer(peer: peer)
            }
        })).runWithMacaroon(macaroon)
    }
    
    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        let request = LNDPayReqString(payReq: paymentRequest)
        lnd.rpcToDecodePayReq(withRequest: request, handler: result(completion, map: {
            PaymentRequest(payReq: $0, raw: paymentRequest)
        })).runWithMacaroon(macaroon)
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<Payment>) -> Void) {
        let request = LNDSendRequest(paymentRequest: paymentRequest.raw, amount: amount)
        lnd.rpcToSendPaymentSync(with: request) { response, error in
            if let errorMessage = response?.paymentError,
                !errorMessage.isEmpty {
                let error = LndApiError.localizedError(errorMessage)
                completion(.failure(error))
            } else if let sendResponse = response {
                completion(.success(Payment(paymentRequest: paymentRequest, sendResponse: sendResponse, amount: amount)))
            } else if let statusMessage = error?.localizedDescription {
                completion(.failure(LndApiError.localizedError(statusMessage)))
            } else {
                completion(.failure(LndApiError.unknownError))
            }
        }.runWithMacaroon(macaroon)
    }
    
    public func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String>) -> Void) {
        let request = LNDInvoice(amount: amount, memo: memo)
        lnd.rpcToAddInvoice(withRequest: request, handler: result(completion, map: { $0.paymentRequest }))
            .runWithMacaroon(macaroon)
    }
    
    public func invoices(completion: @escaping (Result<[Invoice]>) -> Void) {
        lnd.rpcToListInvoices(with: LNDListInvoiceRequest(), handler: result(completion, map: {
            $0.invoicesArray.compactMap {
                guard let invoice = $0 as? LNDInvoice else { return nil }
                return Invoice(invoice: invoice)
            }
        })).runWithMacaroon(macaroon)
    }
    
    public func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        lnd.rpcToSubscribeChannelGraph(withRequest: LNDGraphTopologySubscription(), eventHandler: eventResult(completion, map: {
            GraphTopologyUpdate(graphTopologyUpdate: $0)
        })).runWithMacaroon(macaroon)
    }
    
    public func subscribeInvoices(completion: @escaping (Result<Invoice>) -> Void) {
        lnd.rpcToSubscribeInvoices(withRequest: LNDInvoiceSubscription(), eventHandler: eventResult(completion, map: {
            Invoice(invoice: $0)
        })).runWithMacaroon(macaroon)
    }
    
    public func subscribeTransactions(completion: @escaping (Result<Transaction>) -> Void) {
        lnd.rpcToSubscribeTransactions(with: LNDGetTransactionsRequest(), eventHandler: eventResult(completion, map: {
            Transaction(transaction: $0)
        })).runWithMacaroon(macaroon)
    }
    
    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate>) -> Void) {
        guard let request = LNDCloseChannelRequest(channelPoint: channelPoint, force: force) else {
            completion(.failure(LndApiError.invalidInput))
            return
        }
        lnd.rpcToCloseChannel(with: request, eventHandler: eventResult(completion, map: {
            CloseStatusUpdate(closeStatusUpdate: $0)
        })).runWithMacaroon(macaroon)
    }
}
