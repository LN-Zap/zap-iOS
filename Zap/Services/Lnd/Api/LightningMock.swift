//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
/*
final class LightningMock: LightningProtocol {
    private let info: Info?
    private let nodeInfo: NodeInfo?
    private let newAddress: String?
    private let walletBalance: Satoshi?
    private let channelBalance: Satoshi?
    private let transactions: [Transaction]?
    private let subscribeTransactions: Transaction?
    private let payments: [Transaction]?
    private let channels: [Channel]?
    private let pendingChannels: [Channel]?
    private let connectError: Bool?
    private let openChannelStatusUpdate: OpenStatusUpdate?
    private let closeChannelStatusUpdate: CloseStatusUpdate?
    private let sendCoins: String?
    private let peers: [Peer]?
    private let decodePaymentRequest: PaymentRequest?
    private let sendPayment: Data?
    private let addInvoice: String?
    private let graphTopologyUpdate: GraphTopologyUpdate?
    
    init(
        info: Info? = nil,
        nodeInfo: NodeInfo? = nil,
        newAddress: String? = nil,
        walletBalance: Satoshi? = nil,
        channelBalance: Satoshi? = nil,
        transactions: [Transaction]? = nil,
        subscribeTransactions: Transaction? = nil,
        payments: [Transaction]? = nil,
        channels: [Channel]? = nil,
        pendingChannels: [Channel]? = nil,
        connectError: Bool? = nil,
        openChannelStatusUpdate: OpenStatusUpdate? = nil,
        closeChannelStatusUpdate: CloseStatusUpdate? = nil,
        sendCoins: String? = nil,
        peers: [Peer]? = nil,
        decodePaymentRequest: PaymentRequest? = nil,
        sendPayment: Data? = nil,
        addInvoice: String? = nil,
        graphTopologyUpdate: GraphTopologyUpdate?
        ) {
        self.info = info
        self.nodeInfo = nodeInfo
        self.newAddress = newAddress
        self.walletBalance = walletBalance
        self.channelBalance = channelBalance
        self.transactions = transactions
        self.subscribeTransactions = subscribeTransactions
        self.payments = payments
        self.channels = channels
        self.pendingChannels = pendingChannels
        self.connectError = connectError
        self.openChannelStatusUpdate = openChannelStatusUpdate
        self.closeChannelStatusUpdate = closeChannelStatusUpdate
        self.sendCoins = sendCoins
        self.peers = peers
        self.decodePaymentRequest = decodePaymentRequest
        self.sendPayment = sendPayment
        self.addInvoice = addInvoice
        self.graphTopologyUpdate = graphTopologyUpdate
    }
    
    func info(callback: @escaping (Result<Info>) -> Void) {
        callback(Result(value: info, error: LndError.unknownError))
    }
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        callback(Result(value: nodeInfo, error: LndError.unknownError))
    }
    
    func newAddress(callback: @escaping (Result<String>) -> Void) {
        callback(Result(value: newAddress, error: LndError.unknownError))
    }
    
    func walletBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        callback(Result(value: walletBalance, error: LndError.unknownError))
    }
    
    func channelBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        callback(Result(value: channelBalance, error: LndError.unknownError))
    }
    
    func transactions(callback: @escaping (Result<[Transaction]>) -> Void) {
        callback(Result(value: transactions, error: LndError.unknownError))
    }
    
    func subscribeTransactions(callback: @escaping (Result<Transaction>) -> Void) {
        callback(Result(value: subscribeTransactions, error: LndError.unknownError))
    }
    
    func payments(callback: @escaping (Result<[Transaction]>) -> Void) {
        callback(Result(value: payments, error: LndError.unknownError))
    }
    
    func channels(callback: @escaping (Result<[Channel]>) -> Void) {
        callback(Result(value: channels, error: LndError.unknownError))
    }
    
    func pendingChannels(callback: @escaping (Result<[Channel]>) -> Void) {
        callback(Result(value: pendingChannels, error: LndError.unknownError))
    }
    
    func connect(pubKey: String, host: String, callback: @escaping (Result<Void>) -> Void) {
        if connectError == true {
            callback(Result(value: ()))
        } else {
            callback(Result(error: LndError.unknownError))
        }
    }
    
    func openChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<OpenStatusUpdate>) -> Void) {
        callback(Result(value: openChannelStatusUpdate, error: LndError.unknownError))
    }
    
    func closeChannel(channelPoint: String, callback: @escaping (Result<CloseStatusUpdate>) -> Void) {
        callback(Result(value: closeChannelStatusUpdate, error: LndError.unknownError))
    }
    
    func sendCoins(address: String, amount: Satoshi, callback: @escaping (Result<String>) -> Void) {
        callback(Result(value: sendCoins, error: LndError.unknownError))
    }
    
    func peers(callback: @escaping (Result<[Peer]>) -> Void) {
        callback(Result(value: peers, error: LndError.unknownError))
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        callback(Result(value: decodePaymentRequest, error: LndError.unknownError))
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Result<Data>) -> Void) {
        callback(Result(value: sendPayment, error: LndError.unknownError))
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, callback: @escaping (Result<String>) -> Void) {
        callback(Result(value: addInvoice, error: LndError.unknownError))
    }
    
    func subscribeChannelGraph(callback: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        callback(Result(value: graphTopologyUpdate, error: LndError.unknownError))
    }
}
*/
