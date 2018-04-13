//
//  Zap
//
//  Created by Otto Suess on 05.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation
import LightningRpc

final class Lightning: LightningProtocol {
    private var rpc: LightningRpc.Lightning? {
        if Lnd.instance.lightning == nil {
            print("Lightning not initialized")
        }
        return Lnd.instance.lightning
    }
    
    func info(callback: @escaping (Result<Info>) -> Void) {
        rpc?.rpcToGetInfo(with: GetInfoRequest(), handler: result(callback, map: { Info(getInfoResponse: $0) }))
            .runWithMacaroon()
    }
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        let request = NodeInfoRequest()
        request.pubKey = pubKey
        rpc?.rpcToGetNodeInfo(with: request, handler: result(callback, map: { NodeInfo(nodeInfo: $0) }))
            .runWithMacaroon()
    }
    
    func newAddress(callback: @escaping (Result<String>) -> Void) {
        let request = NewAddressRequest()
        request.type = .nestedPubkeyHash
        rpc?.rpcToNewAddress(with: request, handler: result(callback, map: { $0.address }))
            .runWithMacaroon()
    }
    
    func walletBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        rpc?.rpcToWalletBalance(with: WalletBalanceRequest(), handler: result(callback, map: { Satoshi(value: $0.totalBalance) }))
            .runWithMacaroon()
    }
    
    func channelBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        rpc?.rpcToChannelBalance(with: ChannelBalanceRequest(), handler: result(callback, map: { Satoshi(value: $0.balance) }))
            .runWithMacaroon()
    }
    
    func transactions(callback: @escaping (Result<[Transaction]>) -> Void) {
        rpc?.rpcToGetTransactions(with: GetTransactionsRequest(), handler: result(callback, map: {
            $0.transactionsArray.compactMap {
                guard let transaction = $0 as? LightningRpc.Transaction else { return nil }
                return BlockchainTransaction(transaction: transaction)
            }
        }))
        .runWithMacaroon()
    }
    
    func subscribeTransactions(callback: @escaping (Result<Transaction>) -> Void) {
        rpc?.rpcToSubscribeTransactions(with: GetTransactionsRequest(), eventHandler: eventResult(callback, map: { BlockchainTransaction(transaction: $0) }))
            .runWithMacaroon()
    }
    
    func payments(callback: @escaping (Result<[Transaction]>) -> Void) {        
        rpc?.rpcToListPayments(with: ListPaymentsRequest(), handler: result(callback, map: {
            $0.paymentsArray.compactMap {
                guard let payment = $0 as? LightningRpc.Payment else { return nil }
                return Payment(payment: payment)
            }
        }))
        .runWithMacaroon()
    }
    
    func channels(callback: @escaping (Result<[Channel]>) -> Void) {
        rpc?.rpcToListChannels(with: ListChannelsRequest(), handler: result(callback, map: {
            $0.channelsArray.compactMap { ($0 as? LightningRpc.ActiveChannel)?.channelModel }
        }))
        .runWithMacaroon()
    }
    
    func pendingChannels(callback: @escaping (Result<[Channel]>) -> Void) {
        rpc?.rpcToPendingChannels(with: PendingChannelsRequest(), handler: result(callback, map: {
            let pendingOpenChannels: [Channel] = $0.pendingOpenChannelsArray.compactMap {
                ($0 as? PendingChannelsResponse_PendingOpenChannel)?.channelModel
            }
            let pendingClosingChannels: [Channel] = $0.pendingClosingChannelsArray.compactMap {
                ($0 as? PendingChannelsResponse_ClosedChannel)?.channelModel
            }
            let pendingForceClosingChannels: [Channel] = $0.pendingForceClosingChannelsArray.compactMap {
                ($0 as? PendingChannelsResponse_ForceClosedChannel)?.channelModel
            }
            return pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels
        }))
        .runWithMacaroon()
    }
    
    func connect(pubKey: String, host: String, callback: @escaping (Result<Void>) -> Void) {
        let request = ConnectPeerRequest()
        request.addr = LightningAddress()
        request.addr.pubkey = pubKey
        request.addr.host = host
        
        rpc?.rpcToConnectPeer(with: request, handler: result(callback, map: { _ in () }))
            .runWithMacaroon()
    }
    
    func openChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<OpenStatusUpdate>) -> Void) {
        let request = OpenChannelRequest()
        request.nodePubkeyString = pubKey
        request.localFundingAmount = Int64(truncating: amount)
        
        rpc?.rpcToOpenChannel(with: request, eventHandler: eventResult(callback, map: { OpenStatusUpdate($0) }))
            .runWithMacaroon()
    }
    
    func closeChannel(channelPoint: String, callback: @escaping (Result<CloseStatusUpdate>) -> Void) {
        let channelPointParts = channelPoint.components(separatedBy: ":")
        guard let outputIndex = UInt32(channelPointParts[1]) else {
            callback(Result(error: LndError.invalidInput))
            return
        }
        
        let request = CloseChannelRequest()
        request.channelPoint = ChannelPoint()
        request.channelPoint.outputIndex = outputIndex
        request.channelPoint.fundingTxidBytes = channelPointParts[0].hexEndianSwap().hexadecimal()
        request.force = true
        
        rpc?.rpcToCloseChannel(with: request, eventHandler: eventResult(callback, map: { CloseStatusUpdate($0) }))
            .runWithMacaroon()
    }
    
    func sendCoins(address: String, amount: Satoshi, callback: @escaping (Result<String>) -> Void) {
        let request = SendCoinsRequest()
        request.addr = address
        request.amount = Int64(truncating: amount)
        rpc?.rpcToSendCoins(with: request, handler: result(callback, map: { $0.txid }))
            .runWithMacaroon()
        
    }
    
    func peers(callback: @escaping (Result<[Peer]>) -> Void) {
        rpc?.rpcToListPeers(with: ListPeersRequest(), handler: result(callback, map: {
            $0.peersArray.compactMap {
                guard let peer = $0 as? LightningRpc.Peer else { return nil }
                return Peer(peer: peer)
            }
        }))
        .runWithMacaroon()
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        let request = PayReqString()
        request.payReq = paymentRequest
        
        rpc?.rpcToDecodePayReq(withRequest: request, handler: result(callback, map: {
            PaymentRequest(payReq: $0, raw: paymentRequest)
        }))
        .runWithMacaroon()
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Result<Data>) -> Void) {
        let request = SendRequest()
        request.paymentRequest = paymentRequest.raw
        
        rpc?.rpcToSendPaymentSync(with: request) { response, error in
            if let error = error {
                callback(Result(error: error))
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
        .runWithMacaroon()
    }
    
    func addInvoice(amount: Satoshi, memo: String?, callback: @escaping (Result<String>) -> Void) {
        let request = Invoice()
        request.memo = memo
        request.value = Int64(truncating: amount)
        rpc?.rpcToAddInvoice(withRequest: request, handler: result(callback, map: { $0.paymentRequest }))
            .runWithMacaroon()
    }
}
