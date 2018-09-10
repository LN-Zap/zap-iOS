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
    private let newAddress: BitcoinAddress?
    private let walletBalance: Satoshi?
    private let channelBalance: Satoshi?
    private let transactions: [OnChainConfirmedTransaction]?
    private let subscribeTransactions: OnChainConfirmedTransaction?
    private let payments: [LightningPayment]?
    private let channels: [Channel]?
    private let pendingChannels: [Channel]?
    private let connectError: Bool?
    private let channelPoint: ChannelPoint?
    private let closeChannelStatusUpdate: CloseStatusUpdate?
    private let sendCoins: String?
    private let peers: [Peer]?
    private let decodePaymentRequest: PaymentRequest?
    private let sendPayment: LightningPayment?
    private let addInvoice: String?
    private let graphTopologyUpdate: GraphTopologyUpdate?
    private let closedChannels: [ChannelCloseSummary]?
    private let subscribeInvoices: LightningInvoice?
    private let invoices: [LightningInvoice]?
    
    init(
        info: Info? = Info.Template.testnet,
        nodeInfo: NodeInfo? = nil,
        newAddress: BitcoinAddress? = nil,
        walletBalance: Satoshi? = nil,
        channelBalance: Satoshi? = nil,
        transactions: [OnChainConfirmedTransaction]? = nil,
        subscribeTransactions: OnChainConfirmedTransaction? = nil,
        payments: [LightningPayment]? = nil,
        channels: [Channel]? = nil,
        pendingChannels: [Channel]? = nil,
        connectError: Bool? = nil,
        channelPoint: ChannelPoint? = nil,
        closeChannelStatusUpdate: CloseStatusUpdate? = nil,
        sendCoins: String? = nil,
        peers: [Peer]? = nil,
        decodePaymentRequest: PaymentRequest? = nil,
        sendPayment: LightningPayment? = nil,
        addInvoice: String? = nil,
        graphTopologyUpdate: GraphTopologyUpdate? = nil,
        closedChannels: [ChannelCloseSummary]? = nil,
        subscribeInvoices: LightningInvoice? = nil,
        invoices: [LightningInvoice]? = nil
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
    
    func info(completion: @escaping (Result<Info>) -> Void) {
        completion(Result(value: info, error: LndApiError.unknownError))
    }
    
    func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo>) -> Void) {
        completion(Result(value: nodeInfo, error: LndApiError.unknownError))
    }
    
    func walletBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        completion(Result(value: walletBalance, error: LndApiError.unknownError))
    }
    
    func channelBalance(completion: @escaping (Result<Satoshi>) -> Void) {
        completion(Result(value: channelBalance, error: LndApiError.unknownError))
    }
    
    func transactions(completion: @escaping (Result<[OnChainConfirmedTransaction]>) -> Void) {
        completion(Result(value: transactions, error: LndApiError.unknownError))
    }
    
    func subscribeTransactions(completion: @escaping (Result<OnChainConfirmedTransaction>) -> Void) {
        completion(Result(value: subscribeTransactions, error: LndApiError.unknownError))
    }
    
    func payments(completion: @escaping (Result<[LightningPayment]>) -> Void) {
        completion(Result(value: payments, error: LndApiError.unknownError))
    }
    
    func channels(completion: @escaping (Result<[Channel]>) -> Void) {
        completion(Result(value: channels, error: LndApiError.unknownError))
    }
    
    func pendingChannels(completion: @escaping (Result<[Channel]>) -> Void) {
        completion(Result(value: pendingChannels, error: LndApiError.unknownError))
    }
    
    func connect(pubKey: String, host: String, completion: @escaping (Result<Success>) -> Void) {
        if connectError == true {
            completion(.success(Success()))
        } else {
            completion(.failure(LndApiError.unknownError))
        }
    }

    func peers(completion: @escaping (Result<[Peer]>) -> Void) {
        completion(Result(value: peers, error: LndApiError.unknownError))
    }
    
    func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        completion(Result(value: decodePaymentRequest, error: LndApiError.unknownError))
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<LightningPayment>) -> Void) {
        completion(Result(value: sendPayment, error: LndApiError.unknownError))
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String>) -> Void) {
        completion(Result(value: addInvoice, error: LndApiError.unknownError))
    }
    
    func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate>) -> Void) {
        completion(Result(value: graphTopologyUpdate, error: LndApiError.unknownError))
    }
    
    func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint>) -> Void) {
        completion(Result(value: channelPoint, error: LndApiError.unknownError))
    }
    
    func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate>) -> Void) {
        completion(Result(value: closeChannelStatusUpdate, error: LndApiError.unknownError))
    }
    
    func closedChannels(completion: @escaping (Result<[ChannelCloseSummary]>) -> Void) {
        completion(Result(value: closedChannels, error: LndApiError.unknownError))
    }
    
    func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String>) -> Void) {
        completion(Result(value: sendCoins, error: LndApiError.unknownError))
    }
    
    func invoices(completion: @escaping (Result<[LightningInvoice]>) -> Void) {
        completion(Result(value: invoices, error: LndApiError.unknownError))
    }
    
    func subscribeInvoices(completion: @escaping (Result<LightningInvoice>) -> Void) {
        completion(Result(value: subscribeInvoices, error: LndApiError.unknownError))
    }
    
    func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        completion(Result(value: newAddress, error: LndApiError.unknownError))
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
    
    static let selected: ApiMockTemplate = .mainnet
    
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
            return LightningApiMock(info: Info.Template.mainnet)
        case .transactions:
            return LightningApiMock(
                transactions: [
                    OnChainConfirmedTransaction.template
                ],
                payments: [
                    LightningPayment.template
                ]
            )
        case .everything:
            return LightningApiMock(
                walletBalance: 4_200_000,
                transactions: [
                    OnChainConfirmedTransaction.template
                ],
                payments: [
                    LightningPayment.template
                ],
                channels: [
                    Channel.template
                ],
                decodePaymentRequest: PaymentRequest.Template.testnetFallback,
                sendPayment: LightningPayment.template
            )
        }
    }
}
