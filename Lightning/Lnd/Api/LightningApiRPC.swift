//
//  Zap
//
//  Created by Otto Suess on 05.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

private extension Lnrpc_LightningServiceClient {
    convenience init(configuration: RemoteRPCConfiguration) {
        self.init(address: configuration.url.absoluteString, certificates: configuration.certificate, host: nil)
        self.metadata.add(key: "macaroon", value: configuration.macaroon.hexString())
        self.timeout = Double(Int32.max) // otherwise streaming calls stop working after 10 minutes
    }
}

public final class LightningApiRPC: LightningApiProtocol {
    private let rpc: Lnrpc_LightningService
    
    public init(configuration: RemoteRPCConfiguration) {
        rpc = Lnrpc_LightningServiceClient(configuration: configuration)
    }
    
    public func canConnect(callback: @escaping (Bool) -> Void) {
        do {
            _ = try rpc.getInfo(Lnrpc_GetInfoRequest()) { response, _ in
                callback(response != nil)
            }
        } catch {
            callback(false)
        }
    }
    
    func info(callback: @escaping (Result<Info>) -> Void) {
        _ = try? rpc.getInfo(Lnrpc_GetInfoRequest(), completion: result(callback, map: { Info(getInfoResponse: $0) }))
    }
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        let request = Lnrpc_NodeInfoRequest(pubKey: pubKey)
        _ = try? rpc.getNodeInfo(request, completion: result(callback, map: { NodeInfo(nodeInfo: $0) }))
    }
    
    func newAddress(type: OnChainRequestAddressType, callback: @escaping (Result<String>) -> Void) {
        let request = Lnrpc_NewAddressRequest(type: type)
        _ = try? rpc.newAddress(request, completion: result(callback, map: { $0.address }))
    }
    
    func walletBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        _ = try? rpc.walletBalance(Lnrpc_WalletBalanceRequest(), completion: result(callback, map: { Satoshi(value: $0.totalBalance) }))
    }
    
    func channelBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        _ = try? rpc.channelBalance(Lnrpc_ChannelBalanceRequest(), completion: result(callback, map: { Satoshi(value: $0.balance) }))
    }
    
    func transactions(callback: @escaping (Result<[Transaction]>) -> Void) {
        _ = try? rpc.getTransactions(Lnrpc_GetTransactionsRequest(), completion: result(callback, map: {
            $0.transactions.compactMap { OnChainTransaction(transaction: $0) }
        }))
    }
    
    func payments(callback: @escaping (Result<[Transaction]>) -> Void) {        
        _ = try? rpc.listPayments(Lnrpc_ListPaymentsRequest(), completion: result(callback, map: {
            $0.payments.compactMap { LightningPayment(payment: $0) }
        }))
    }
    
    func channels(callback: @escaping (Result<[Channel]>) -> Void) {
        _ = try? rpc.listChannels(Lnrpc_ListChannelsRequest(), completion: result(callback, map: {
            $0.channels.compactMap { $0.channelModel }
        }))
    }
    
    func pendingChannels(callback: @escaping (Result<[Channel]>) -> Void) {
        _ = try? rpc.pendingChannels(Lnrpc_PendingChannelsRequest(), completion: result(callback, map: {
            let pendingOpenChannels: [Channel] = $0.pendingOpenChannels.compactMap { $0.channelModel }
            let pendingClosingChannels: [Channel] = $0.pendingClosingChannels.compactMap { $0.channelModel }
            let pendingForceClosingChannels: [Channel] = $0.pendingForceClosingChannels.compactMap { $0.channelModel }
            return pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels
        }))
    }
    
    func connect(pubKey: String, host: String, callback: @escaping (Result<Void>) -> Void) {
        let request = Lnrpc_ConnectPeerRequest(pubKey: pubKey, host: host)        
        _ = try? rpc.connectPeer(request, completion: result(callback, map: { _ in () }))
    }
    
    func openChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<ChannelPoint>) -> Void) {
        let request = Lnrpc_OpenChannelRequest(pubKey: pubKey, amount: amount)
        _ = try? rpc.openChannelSync(request, completion: result(callback, map: { ChannelPoint(channelPoint: $0) }))
    }
    
    func sendCoins(address: String, amount: Satoshi, callback: @escaping (Result<String>) -> Void) {
        let request = Lnrpc_SendCoinsRequest(address: address, amount: amount)
        _ = try? rpc.sendCoins(request, completion: result(callback, map: { $0.txid }))
    }
    
    func peers(callback: @escaping (Result<[Peer]>) -> Void) {
        _ = try? rpc.listPeers(Lnrpc_ListPeersRequest(), completion: result(callback, map: {
            $0.peers.compactMap { Peer(peer: $0) }
        }))
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        let request = Lnrpc_PayReqString(payReq: paymentRequest)
        _ = try? rpc.decodePayReq(request, completion: result(callback, map: {
            PaymentRequest(payReq: $0, raw: paymentRequest)
        }))
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Result<Data>) -> Void) {
        let request = Lnrpc_SendRequest(paymentRequest: paymentRequest.raw)
        _ = try? rpc.sendPaymentSync(request) { response, error in
            if !error.success {
                callback(Result(error: LndApiError.unknownError))
            } else if let errorMessage = response?.paymentError,
                !errorMessage.isEmpty {
                let error = LndApiError.localizedError(errorMessage)
                callback(Result(error: error))
            } else if let response = response {
                callback(Result(value: response.paymentPreimage))
            } else if let statusMessage = error.statusMessage {
                callback(Result(error: LndApiError.localizedError(statusMessage)))
            } else {
                callback(Result(error: LndApiError.unknownError))
            }
        }
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, callback: @escaping (Result<String>) -> Void) {
        let request = Lnrpc_Invoice(amount: amount, memo: memo)
        _ = try? rpc.addInvoice(request, completion: result(callback, map: { $0.paymentRequest }))
    }
    
    func invoices(callback: @escaping (Result<[Transaction]>) -> Void) {
        _ = try? rpc.listInvoices(Lnrpc_ListInvoiceRequest(), completion: result(callback, map: {
            $0.invoices.compactMap { LightningInvoice(invoice: $0) }
        }))
    }
    
    func subscribeChannelGraph(callback: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        do {
            let call = try rpc.subscribeChannelGraph(Lnrpc_GraphTopologySubscription(), completion: { print(#function, $0) })
            try receiveChannelGraphUpdate(call: call, callback: callback)
        } catch {
            print(error)
        }
    }
    
    func subscribeInvoices(callback: @escaping (Result<Transaction>) -> Void) {
        do {
            let call = try rpc.subscribeInvoices(Lnrpc_InvoiceSubscription(), completion: { print(#function, $0) })
            try receiveInvoicesUpdate(call: call, callback: callback)
        } catch {
            print(error)
        }
    }
    
    func subscribeTransactions(callback: @escaping (Result<Transaction>) -> Void) {
        do {
            let call = try rpc.subscribeTransactions(Lnrpc_GetTransactionsRequest(), completion: { print(#function, $0) })
            try receiveTransactionsUpdate(call: call, callback: callback)
        } catch {
           print(error)
        }
    }
    
    func closeChannel(channelPoint: String, force: Bool, callback: @escaping (Result<CloseStatusUpdate>) -> Void) {
        guard let request = Lnrpc_CloseChannelRequest(channelPoint: channelPoint, force: force) else {
            callback(Result(error: LndApiError.invalidInput))
            return
        }
        do {
            let call = try rpc.closeChannel(request, completion: { print(#function, "🏞 Result:", $0) })
            try receiveCloseChannelUpdate(call: call, callback: callback)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Streaming helper methods

    private func receiveChannelGraphUpdate(call: Lnrpc_LightningSubscribeChannelGraphCall, callback: @escaping (Result<GraphTopologyUpdate>) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                callback(Result(value: GraphTopologyUpdate(graphTopologyUpdate: result)))
            } else if let error = $0.error {
                print(#function, error)
            }
            try? self?.receiveChannelGraphUpdate(call: call, callback: callback)
        }
    }
    
    private func receiveInvoicesUpdate(call: Lnrpc_LightningSubscribeInvoicesCall, callback: @escaping (Result<Transaction>) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                callback(Result(value: LightningInvoice(invoice: result)))
            } else if let error = $0.error {
                print(#function, error)
            }
            try? self?.receiveInvoicesUpdate(call: call, callback: callback)
        }
    }
    
    private func receiveTransactionsUpdate(call: Lnrpc_LightningSubscribeTransactionsCall, callback: @escaping (Result<Transaction>) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                callback(Result(value: OnChainTransaction(transaction: result)))
            } else if let error = $0.error {
                print(#function, error)
            }
            try? self?.receiveTransactionsUpdate(call: call, callback: callback)
        }
    }
    
    private func receiveCloseChannelUpdate(call: Lnrpc_LightningCloseChannelCall, callback: @escaping (Result<CloseStatusUpdate>) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                callback(Result(value: CloseStatusUpdate(closeStatusUpdate: result)))
            } else if let error = $0.error {
                print(#function, error)
            }
            try? self?.receiveCloseChannelUpdate(call: call, callback: callback)
        }
    }
}
