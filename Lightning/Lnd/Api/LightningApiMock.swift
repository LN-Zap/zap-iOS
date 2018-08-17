//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

final class LightningApiMock: LightningApiProtocol {
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
    private let channelPoint: ChannelPoint?
    private let closeChannelStatusUpdate: CloseStatusUpdate?
    private let sendCoins: OnChainUnconfirmedTransaction?
    private let peers: [Peer]?
    private let decodePaymentRequest: PaymentRequest?
    private let sendPayment: Data?
    private let addInvoice: String?
    private let graphTopologyUpdate: GraphTopologyUpdate?
    private let closedChannels: [ChannelCloseSummary]?
    private let subscribeInvoices: Transaction?
    private let invoices: [Transaction]?
    
    init(
        info: Info? = Info.template.testnet,
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
        channelPoint: ChannelPoint? = nil,
        closeChannelStatusUpdate: CloseStatusUpdate? = nil,
        sendCoins: OnChainUnconfirmedTransaction? = nil,
        peers: [Peer]? = nil,
        decodePaymentRequest: PaymentRequest? = nil,
        sendPayment: Data? = nil,
        addInvoice: String? = nil,
        graphTopologyUpdate: GraphTopologyUpdate? = nil,
        closedChannels: [ChannelCloseSummary]? = nil,
        subscribeInvoices: Transaction? = nil,
        invoices: [Transaction]? = nil
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
        self.channelPoint = channelPoint
        self.closeChannelStatusUpdate = closeChannelStatusUpdate
        self.sendCoins = sendCoins
        self.peers = peers
        self.decodePaymentRequest = decodePaymentRequest
        self.sendPayment = sendPayment
        self.addInvoice = addInvoice
        self.graphTopologyUpdate = graphTopologyUpdate
        self.closedChannels = closedChannels
        self.subscribeInvoices = subscribeInvoices
        self.invoices = invoices
    }
    
    func info(callback: @escaping (Result<Info>) -> Void) {
        callback(Result(value: info, error: LndApiError.unknownError))
    }
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        callback(Result(value: nodeInfo, error: LndApiError.unknownError))
    }
    
    func walletBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        callback(Result(value: walletBalance, error: LndApiError.unknownError))
    }
    
    func channelBalance(callback: @escaping (Result<Satoshi>) -> Void) {
        callback(Result(value: channelBalance, error: LndApiError.unknownError))
    }
    
    func transactions(callback: @escaping (Result<[Transaction]>) -> Void) {
        callback(Result(value: transactions, error: LndApiError.unknownError))
    }
    
    func subscribeTransactions(callback: @escaping (Result<Transaction>) -> Void) {
        callback(Result(value: subscribeTransactions, error: LndApiError.unknownError))
    }
    
    func payments(callback: @escaping (Result<[Transaction]>) -> Void) {
        callback(Result(value: payments, error: LndApiError.unknownError))
    }
    
    func channels(callback: @escaping (Result<[Channel]>) -> Void) {
        callback(Result(value: channels, error: LndApiError.unknownError))
    }
    
    func pendingChannels(callback: @escaping (Result<[Channel]>) -> Void) {
        callback(Result(value: pendingChannels, error: LndApiError.unknownError))
    }
    
    func connect(pubKey: String, host: String, callback: @escaping (Result<Success>) -> Void) {
        if connectError == true {
            callback(Result(value: Success()))
        } else {
            callback(Result(error: LndApiError.unknownError))
        }
    }

    func peers(callback: @escaping (Result<[Peer]>) -> Void) {
        callback(Result(value: peers, error: LndApiError.unknownError))
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        callback(Result(value: decodePaymentRequest, error: LndApiError.unknownError))
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Result<Data>) -> Void) {
        callback(Result(value: sendPayment, error: LndApiError.unknownError))
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, callback: @escaping (Result<String>) -> Void) {
        callback(Result(value: addInvoice, error: LndApiError.unknownError))
    }
    
    func subscribeChannelGraph(callback: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        callback(Result(value: graphTopologyUpdate, error: LndApiError.unknownError))
    }
    
    func openChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<ChannelPoint>) -> Void) {
        callback(Result(value: channelPoint, error: LndApiError.unknownError))
    }
    
    func closeChannel(channelPoint: ChannelPoint, force: Bool, callback: @escaping (Result<CloseStatusUpdate>) -> Void) {
        callback(Result(value: closeChannelStatusUpdate, error: LndApiError.unknownError))
    }
    
    func closedChannels(callback: @escaping (Result<[ChannelCloseSummary]>) -> Void) {
        callback(Result(value: closedChannels, error: LndApiError.unknownError))
    }
    
    func sendCoins(address: String, amount: Satoshi, callback: @escaping (Result<OnChainUnconfirmedTransaction>) -> Void) {
        callback(Result(value: sendCoins, error: LndApiError.unknownError))
    }
    
    func invoices(callback: @escaping (Result<[Transaction]>) -> Void) {
        callback(Result(value: invoices, error: LndApiError.unknownError))
    }
    
    func subscribeInvoices(callback: @escaping (Result<Transaction>) -> Void) {
        callback(Result(value: subscribeInvoices, error: LndApiError.unknownError))
    }
    
    func newAddress(type: OnChainRequestAddressType, callback: @escaping (Result<String>) -> Void) {
        callback(Result(value: newAddress, error: LndApiError.unknownError))
    }
}

enum ApiMockTemplate {
    case syncedEmpty
    case oneChannel
    case manyChannels
    case balance
    case mainnet
    case transactions
    case everything
    
    static let selected: ApiMockTemplate = .everything
    
    var instance: LightningApiMock {
        switch self {
        case .syncedEmpty:
            return LightningApiMock()
        case .oneChannel:
            return LightningApiMock(channels: [Channel.template])
        case .manyChannels:
            return LightningApiMock(channels: Array(repeating: Channel.template, count: 200))
        case .balance:
            return LightningApiMock(walletBalance: 4_200_000)
        case .mainnet:
            return LightningApiMock(info: Info.template.mainnet)
        case .transactions:
            return LightningApiMock(transactions: [
                OnChainConfirmedTransaction.template,
                OnChainUnconfirmedTransaction.template,
                LightningPayment.template
            ])
        case .everything:
            return LightningApiMock(
                walletBalance: 4_200_000,
                transactions: [
                    OnChainConfirmedTransaction.template,
                    OnChainUnconfirmedTransaction.template,
                    LightningPayment.template
                ],
                channels: [
                    Channel.template
                ]
            )
        }
    }
}
