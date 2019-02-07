//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

private extension Result {
    init(value: Success?, error: Failure) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
}

final class LightningApiMock: LightningApiProtocol {
    private let info: Info?
    private let nodeInfo: NodeInfo?
    private let newAddress: BitcoinAddress?
    private let walletBalance: Satoshi?
    private let channelBalance: Satoshi?
    private let transactions: [Transaction]?
    private let subscribeTransactions: Transaction?
    private let payments: [Payment]?
    private let channels: [Channel]?
    private let pendingChannels: [Channel]?
    private let connectError: Bool?
    private let channelPoint: ChannelPoint?
    private let closeChannelStatusUpdate: CloseStatusUpdate?
    private let sendCoins: String?
    private let peers: [Peer]?
    private let decodePaymentRequest: PaymentRequest?
    private let sendPayment: Payment?
    private let addInvoice: String?
    private let graphTopologyUpdate: GraphTopologyUpdate?
    private let closedChannels: [ChannelCloseSummary]?
    private let subscribeInvoices: Invoice?
    private let invoices: [Invoice]?
    private let routes: [Route]?
    
    public var subscribeTransactionsCallback: ((Result<Transaction, LndApiError>) -> Void)?
    
    init(
        info: Info? = Info.Template.testnet,
        nodeInfo: NodeInfo? = nil,
        newAddress: BitcoinAddress? = nil,
        walletBalance: Satoshi? = nil,
        channelBalance: Satoshi? = nil,
        transactions: [Transaction]? = nil,
        subscribeTransactions: Transaction? = nil,
        payments: [Payment]? = nil,
        channels: [Channel]? = nil,
        pendingChannels: [Channel]? = nil,
        connectError: Bool? = nil,
        channelPoint: ChannelPoint? = nil,
        closeChannelStatusUpdate: CloseStatusUpdate? = nil,
        sendCoins: String? = nil,
        peers: [Peer]? = nil,
        decodePaymentRequest: PaymentRequest? = nil,
        sendPayment: Payment? = nil,
        addInvoice: String? = nil,
        graphTopologyUpdate: GraphTopologyUpdate? = nil,
        closedChannels: [ChannelCloseSummary]? = nil,
        subscribeInvoices: Invoice? = nil,
        invoices: [Invoice]? = nil,
        routes: [Route]? = nil
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
        self.routes = routes
    }
    
    func info(completion: @escaping (Result<Info, LndApiError>) -> Void) {
        completion(Result(value: info, error: LndApiError.unknownError))
    }
    
    func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo, LndApiError>) -> Void) {
        completion(Result(value: nodeInfo, error: LndApiError.unknownError))
    }
    
    func walletBalance(completion: @escaping (Result<Satoshi, LndApiError>) -> Void) {
        completion(Result(value: walletBalance, error: LndApiError.unknownError))
    }
    
    func channelBalance(completion: @escaping (Result<Satoshi, LndApiError>) -> Void) {
        completion(Result(value: channelBalance, error: LndApiError.unknownError))
    }
    
    func transactions(completion: @escaping (Result<[Transaction], LndApiError>) -> Void) {
        completion(Result(value: transactions, error: LndApiError.unknownError))
    }
    
    func subscribeTransactions(completion: @escaping (Result<Transaction, LndApiError>) -> Void) {
        self.subscribeTransactionsCallback = completion
    }
    
    func payments(completion: @escaping (Result<[Payment], LndApiError>) -> Void) {
        completion(Result(value: payments, error: LndApiError.unknownError))
    }
    
    func channels(completion: @escaping (Result<[Channel], LndApiError>) -> Void) {
        completion(Result(value: channels, error: LndApiError.unknownError))
    }
    
    func pendingChannels(completion: @escaping (Result<[Channel], LndApiError>) -> Void) {
        completion(Result(value: pendingChannels, error: LndApiError.unknownError))
    }
    
    func connect(pubKey: String, host: String, completion: @escaping (Result<Success, LndApiError>) -> Void) {
        if connectError == true {
            completion(.success(Success()))
        } else {
            completion(.failure(LndApiError.unknownError))
        }
    }

    func peers(completion: @escaping (Result<[Peer], LndApiError>) -> Void) {
        completion(Result(value: peers, error: LndApiError.unknownError))
    }
    
    func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest, LndApiError>) -> Void) {
        completion(Result(value: decodePaymentRequest, error: LndApiError.unknownError))
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<Payment, LndApiError>) -> Void) {
        completion(Result(value: sendPayment, error: LndApiError.unknownError))
    }
    
    func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String, LndApiError>) -> Void) {
        completion(Result(value: addInvoice, error: LndApiError.unknownError))
    }
    
    func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate, LndApiError>) -> Void) {
        completion(Result(value: graphTopologyUpdate, error: LndApiError.unknownError))
    }
    
    func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint, LndApiError>) -> Void) {
        completion(Result(value: channelPoint, error: LndApiError.unknownError))
    }
    
    func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate, LndApiError>) -> Void) {
        completion(Result(value: closeChannelStatusUpdate, error: LndApiError.unknownError))
    }
    
    func closedChannels(completion: @escaping (Result<[ChannelCloseSummary], LndApiError>) -> Void) {
        completion(Result(value: closedChannels, error: LndApiError.unknownError))
    }
    
    func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String, LndApiError>) -> Void) {
        completion(Result(value: sendCoins, error: LndApiError.unknownError))
    }
    
    func invoices(completion: @escaping (Result<[Invoice], LndApiError>) -> Void) {
        completion(Result(value: invoices, error: LndApiError.unknownError))
    }
    
    func subscribeInvoices(completion: @escaping (Result<Invoice, LndApiError>) -> Void) {
        completion(Result(value: subscribeInvoices, error: LndApiError.unknownError))
    }
    
    func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress, LndApiError>) -> Void) {
        completion(Result(value: newAddress, error: LndApiError.unknownError))
    }
    
    func routes(destination: String, amount: Satoshi, completion: @escaping (Result<[Route], LndApiError>) -> Void) {
        completion(Result(value: routes, error: LndApiError.unknownError))
    }
}

public enum ApiMockTemplate {
    case syncedEmpty
    case oneChannel
    case manyChannels
    case balance
    case mainnet
    case transactions
    case everything
    
    public static let selected: ApiMockTemplate = .transactions
    
    public var instance: LightningApiProtocol {
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
                walletBalance: 100000,
                transactions: [
                    Transaction.template
                ],
                payments: [
                    Payment.template
                ]
            )
        case .everything:
            return LightningApiMock(
                walletBalance: 4_200_000,
                transactions: [
                    Transaction.template
                ],
                payments: [
                    Payment.template
                ],
                channels: [
                    Channel.template
                ],
                decodePaymentRequest: PaymentRequest.Template.testnetFallback,
                sendPayment: Payment.template
            )
        }
    }
}
