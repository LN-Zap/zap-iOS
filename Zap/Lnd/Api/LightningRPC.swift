//
//  Zap
//
//  Created by Otto Suess on 05.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//
/*
import BTCUtil
import Foundation

final class LightningRPC: LightningProtocol {
    private var rpc: Lnrpc_LightningService? {
        if Lnd.instance.lightning == nil {
            print("Lightning not initialized")
        }
        return Lnd.instance.lightning
    }
    
    func info(callback: @escaping (Result<Info>) -> Void) {
        _ = try? rpc?.getInfo(Lnrpc_GetInfoRequest(), completion: result(callback, map: { Info(getInfoResponse: $0) }))
    }
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        let request = Lnrpc_NodeInfoRequest(pubKey: pubKey)
        _ = try? rpc?.getNodeInfo(request, completion: result(callback, map: { NodeInfo(nodeInfo: $0) }))
    }
    
    func newAddress(callback: @escaping (Result<String>) -> Void) {
        let request = Lnrpc_NewAddressRequest(type: .nestedPubkeyHash)
        _ = try? rpc?.newAddress(request, completion: result(callback, map: { $0.address }))
    }
    
    func walletBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        _ = try? rpc?.walletBalance(Lnrpc_WalletBalanceRequest(), completion: result(callback, map: { Satoshi(value: $0.totalBalance) }))
    }
    
    func channelBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        _ = try? rpc?.channelBalance(Lnrpc_ChannelBalanceRequest(), completion: result(callback, map: { Satoshi(value: $0.balance) }))
    }
    
    func transactions(callback: @escaping (Result<[Transaction]>) -> Void) {
        _ = try? rpc?.getTransactions(Lnrpc_GetTransactionsRequest(), completion: result(callback, map: {
            $0.transactions.compactMap { BlockchainTransaction(transaction: $0) }
        }))
    }
    
    func subscribeTransactions(callback: @escaping (Result<Transaction>) -> Void) {
        _ = try? rpc?.subscribeTransactions(Lnrpc_GetTransactionsRequest(), completion: { _ in
            fatalError("not implemented")
        })
    }
    
    func payments(callback: @escaping (Result<[Transaction]>) -> Void) {        
        _ = try? rpc?.listPayments(Lnrpc_ListPaymentsRequest(), completion: result(callback, map: {
            $0.payments.compactMap { Payment(payment: $0) }
        }))
    }
    
    func channels(callback: @escaping (Result<[Channel]>) -> Void) {
        _ = try? rpc?.listChannels(Lnrpc_ListChannelsRequest(), completion: result(callback, map: {
            $0.channels.compactMap { $0.channelModel }
        }))
    }
    
    func pendingChannels(callback: @escaping (Result<[Channel]>) -> Void) {
        _ = try? rpc?.pendingChannels(Lnrpc_PendingChannelsRequest(), completion: result(callback, map: {
            let pendingOpenChannels: [Channel] = $0.pendingOpenChannels.compactMap { $0.channelModel }
            let pendingClosingChannels: [Channel] = $0.pendingClosingChannels.compactMap { $0.channelModel }
            let pendingForceClosingChannels: [Channel] = $0.pendingForceClosingChannels.compactMap { $0.channelModel }
            return pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels
        }))
    }
    
    func connect(pubKey: String, host: String, callback: @escaping (Result<Void>) -> Void) {
        let request = Lnrpc_ConnectPeerRequest(pubKey: pubKey, host: host)        
        _ = try? rpc?.connectPeer(request, completion: result(callback, map: { _ in () }))
    }
    
    func openChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<OpenStatusUpdate>) -> Void) {
        let request = Lnrpc_OpenChannelRequest(pubKey: pubKey, amount: amount)
        _ = try? rpc?.openChannel(request, completion: { _ in
            fatalError("not implemented")
        })
    }
    
    func closeChannel(channelPoint: String, callback: @escaping (Result<CloseStatusUpdate>) -> Void) {
        guard let request = Lnrpc_CloseChannelRequest(channelPoint: channelPoint) else {
            callback(Result(error: LndError.invalidInput))
            return
        }
        _ = try? rpc?.closeChannel(request, completion: { _ in
            fatalError("not implemented")
        })
    }
    
    func sendCoins(address: String, amount: Satoshi, callback: @escaping (Result<String>) -> Void) {
        let request = Lnrpc_SendCoinsRequest(address: address, amount: amount)
        _ = try? rpc?.sendCoins(request, completion: result(callback, map: { $0.txid }))
    }
    
    func peers(callback: @escaping (Result<[Peer]>) -> Void) {
        _ = try? rpc?.listPeers(Lnrpc_ListPeersRequest(), completion: result(callback, map: {
            $0.peers.compactMap { Peer(peer: $0) }
        }))
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        let request = Lnrpc_PayReqString(payReq: paymentRequest)
        _ = try? rpc?.decodePayReq(request, completion: result(callback, map: {
            PaymentRequest(payReq: $0, raw: paymentRequest)
        }))
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Result<Data>) -> Void) {
        let request = Lnrpc_SendRequest(paymentRequest: paymentRequest.raw)
        _ = try? rpc?.sendPaymentSync(request) { response, error in
            if !error.success {
                callback(Result(error: LndError.unknownError))
            } else if let errorMessage = response?.paymentError,
                !errorMessage.isEmpty {
                let error = LndError.localizedError(errorMessage)
                callback(Result(error: error))
            } else if let response = response {
                callback(Result(value: response.paymentPreimage))
            } else {
                callback(Result(error: LndError.unknownError))
            }
        }
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, callback: @escaping (Result<String>) -> Void) {
        let request = Lnrpc_Invoice(amount: amount, memo: memo)
        _ = try? rpc?.addInvoice(request, completion: result(callback, map: { $0.paymentRequest }))
    }
    
    func subscribeChannelGraph(callback: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        fatalError("not implemented")
    }
}
*/

