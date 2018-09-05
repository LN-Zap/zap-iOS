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
        setenv("GRPC_SSL_CIPHER_SUITES", "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384", 1)
        
        if let certificate = configuration.certificate {
            self.init(address: configuration.url.absoluteString, certificates: certificate)
        } else {
            self.init(address: configuration.url.absoluteString)
        }
        
        try? metadata.add(key: "macaroon", value: configuration.macaroon.hexString())
        timeout = Double(Int32.max) // otherwise streaming calls stop working after 10 minutes
    }
}

public final class LightningApiRPC: LightningApiProtocol {
    private let rpc: Lnrpc_LightningService
    
    public init(configuration: RemoteRPCConfiguration) {
        rpc = Lnrpc_LightningServiceClient(configuration: configuration)
    }
    
    public func canConnect(completion: @escaping (Bool) -> Void) {
        do {
            _ = try rpc.getInfo(Lnrpc_GetInfoRequest()) { response, _ in
                completion(response != nil)
            }
        } catch {
            completion(false)
        }
    }
    
    func info(completion: @escaping (Result<Info>) -> Void) {
        _ = try? rpc.getInfo(Lnrpc_GetInfoRequest(), completion: result(completion, map: { Info(getInfoResponse: $0) }))
    }
    
    func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo>) -> Void) {
        let request = Lnrpc_NodeInfoRequest(pubKey: pubKey)
        _ = try? rpc.getNodeInfo(request, completion: result(completion, map: { NodeInfo(nodeInfo: $0) }))
    }
    
    func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        let request = Lnrpc_NewAddressRequest(type: type)
        _ = try? rpc.newAddress(request, completion: result(completion, map: {
            BitcoinAddress(string: $0.address)
        }))
    }
    
    func walletBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        _ = try? rpc.walletBalance(Lnrpc_WalletBalanceRequest(), completion: result(completion, map: { Satoshi($0.totalBalance) }))
    }
    
    func channelBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        _ = try? rpc.channelBalance(Lnrpc_ChannelBalanceRequest(), completion: result(completion, map: { Satoshi($0.balance) }))
    }
    
    func transactions(completion: @escaping (Result<[Transaction]>) -> Void) {
        _ = try? rpc.getTransactions(Lnrpc_GetTransactionsRequest(), completion: result(completion, map: {
            $0.transactions.compactMap { OnChainConfirmedTransaction(transaction: $0) }
        }))
    }
    
    func payments(completion: @escaping (Result<[Transaction]>) -> Void) {        
        _ = try? rpc.listPayments(Lnrpc_ListPaymentsRequest(), completion: result(completion, map: {
            $0.payments.compactMap { LightningPayment(payment: $0) }
        }))
    }
    
    func channels(completion: @escaping (Result<[Channel]>) -> Void) {
        _ = try? rpc.listChannels(Lnrpc_ListChannelsRequest(), completion: result(completion, map: {
            $0.channels.compactMap { $0.channelModel }
        }))
    }
    
    func closedChannels(completion: @escaping (Result<[ChannelCloseSummary]>) -> Void) {
        _ = try? rpc.closedChannels(Lnrpc_ClosedChannelsRequest(), completion: result(completion, map: {
            $0.channels.map { ChannelCloseSummary(channelCloseSummary: $0) }
        }))
    }
    
    func pendingChannels(completion: @escaping (Result<[Channel]>) -> Void) {
        _ = try? rpc.pendingChannels(Lnrpc_PendingChannelsRequest(), completion: result(completion, map: {
            let pendingOpenChannels: [Channel] = $0.pendingOpenChannels.compactMap { $0.channelModel }
            let pendingClosingChannels: [Channel] = $0.pendingClosingChannels.compactMap { $0.channelModel }
            let pendingForceClosingChannels: [Channel] = $0.pendingForceClosingChannels.compactMap { $0.channelModel }
            return pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels
        }))
    }
    
    func connect(pubKey: String, host: String, completion: @escaping (Result<Success>) -> Void) {
        let request = Lnrpc_ConnectPeerRequest(pubKey: pubKey, host: host)        
        _ = try? rpc.connectPeer(request, completion: result(completion, map: { _ in Success() }))
    }
    
    func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint>) -> Void) {
        let request = Lnrpc_OpenChannelRequest(pubKey: pubKey, amount: amount)
        _ = try? rpc.openChannelSync(request, completion: result(completion, map: { ChannelPoint(channelPoint: $0) }))
    }
    
    func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<OnChainUnconfirmedTransaction>) -> Void) {
        let request = Lnrpc_SendCoinsRequest(address: address, amount: amount)
        _ = try? rpc.sendCoins(request, completion: result(completion, map: {
            OnChainUnconfirmedTransaction(id: $0.txid, amount: -amount, date: Date(), destinationAddresses: [address])
        }))
    }
    
    func peers(completion: @escaping (Result<[Peer]>) -> Void) {
        _ = try? rpc.listPeers(Lnrpc_ListPeersRequest(), completion: result(completion, map: {
            $0.peers.compactMap { Peer(peer: $0) }
        }))
    }
    
    func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        let request = Lnrpc_PayReqString(payReq: paymentRequest)
        _ = try? rpc.decodePayReq(request, completion: result(completion, map: {
            PaymentRequest(payReq: $0, raw: paymentRequest)
        }))
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<LightningPayment>) -> Void) {
        let request = Lnrpc_SendRequest(paymentRequest: paymentRequest.raw, amount: amount)
        _ = try? rpc.sendPaymentSync(request) { response, error in
            if !error.success {
                completion(.failure(LndApiError.unknownError))
            } else if let errorMessage = response?.paymentError,
                !errorMessage.isEmpty {
                let error = LndApiError.localizedError(errorMessage)
                completion(.failure(error))
            } else if let sendResponse = response {
                completion(.success(LightningPayment(paymentRequest: paymentRequest, sendResponse: sendResponse)))
            } else if let statusMessage = error.statusMessage {
                completion(.failure(LndApiError.localizedError(statusMessage)))
            } else {
                completion(.failure(LndApiError.unknownError))
            }
        }
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String>) -> Void) {
        let request = Lnrpc_Invoice(amount: amount, memo: memo)
        _ = try? rpc.addInvoice(request, completion: result(completion, map: { $0.paymentRequest }))
    }
    
    func invoices(completion: @escaping (Result<[Transaction]>) -> Void) {
        _ = try? rpc.listInvoices(Lnrpc_ListInvoiceRequest(), completion: result(completion, map: {
            $0.invoices.compactMap { LightningInvoice(invoice: $0) }
        }))
    }
    
    func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        do {
            let call = try rpc.subscribeChannelGraph(Lnrpc_GraphTopologySubscription(), completion: { print(#function, $0) })
            try receiveChannelGraphUpdate(call: call, completion: completion)
        } catch {
            print(error)
        }
    }
    
    func subscribeInvoices(completion: @escaping (Result<Transaction>) -> Void) {
        do {
            let call = try rpc.subscribeInvoices(Lnrpc_InvoiceSubscription(), completion: { print(#function, $0) })
            try receiveInvoicesUpdate(call: call, completion: completion)
        } catch {
            print(error)
        }
    }
    
    func subscribeTransactions(completion: @escaping (Result<Transaction>) -> Void) {
        do {
            let call = try rpc.subscribeTransactions(Lnrpc_GetTransactionsRequest(), completion: { print(#function, $0) })
            try receiveTransactionsUpdate(call: call, completion: completion)
        } catch {
           print(error)
        }
    }
    
    func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate>) -> Void) {
        guard let request = Lnrpc_CloseChannelRequest(channelPoint: channelPoint, force: force) else {
            completion(.failure(LndApiError.invalidInput))
            return
        }
        do {
            let call = try rpc.closeChannel(request, completion: { print(#function, "🏞 Result:", $0) })
            try receiveCloseChannelUpdate(call: call, completion: completion)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Streaming helper methods

    private func receiveChannelGraphUpdate(call: Lnrpc_LightningSubscribeChannelGraphCall, completion: @escaping (Result<GraphTopologyUpdate>) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                completion(.success(GraphTopologyUpdate(graphTopologyUpdate: result)))
            } else if let error = $0.error {
                print(#function, error)
            }
            try? self?.receiveChannelGraphUpdate(call: call, completion: completion)
        }
    }
    
    private func receiveInvoicesUpdate(call: Lnrpc_LightningSubscribeInvoicesCall, completion: @escaping (Result<Transaction>) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                completion(.success(LightningInvoice(invoice: result)))
            } else if let error = $0.error {
                print(#function, error)
            }
            try? self?.receiveInvoicesUpdate(call: call, completion: completion)
        }
    }
    
    private func receiveTransactionsUpdate(call: Lnrpc_LightningSubscribeTransactionsCall, completion: @escaping (Result<Transaction>) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                completion(.success(OnChainConfirmedTransaction(transaction: result)))
            } else if let error = $0.error {
                print(#function, error)
            }
            try? self?.receiveTransactionsUpdate(call: call, completion: completion)
        }
    }
    
    private func receiveCloseChannelUpdate(call: Lnrpc_LightningCloseChannelCall, completion: @escaping (Result<CloseStatusUpdate>) -> Void) throws {
        try call.receive { [weak self] in
            if let result = $0.result.flatMap({ $0 }) {
                completion(.success(CloseStatusUpdate(closeStatusUpdate: result)))
            } else if let error = $0.error {
                print(#function, error)
            }
            try? self?.receiveCloseChannelUpdate(call: call, completion: completion)
        }
    }
}
