//
//  SwiftLnd
//
//  Created by 0 on 29.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import SwiftBTC

public final class LightningApi {
    public enum Kind {
        case stream
        case grpc(RPCCredentials)
        case tor(RPCCredentials, URLSessionConfiguration)
        case mock(ApiMockTemplate)

        func createConnection() -> LightningConnection {
            switch self {
            case .stream:
                #if !REMOTEONLY
                return StreamingLightningConnection()
                #else
                fatalError("local connection not available")
                #endif
            case .grpc(let configuration):
                return RPCLightningConnection(configuration: configuration)
            case let .tor(configuration, urlSessionConfiguration):
                let restClient = LNDRest(credentials: configuration, urlSessionConfiguration: urlSessionConfiguration)
                return RestLightningConnection(lndRest: restClient)
            case .mock(let template):
                return template.instance
            }
        }
    }

    private var connection: LightningConnection
    private let kind: Kind? // to be able to reset the connection if needed

    public init(connection kind: Kind) {
        self.kind = kind
        self.connection = kind.createConnection()
    }

    /// Should only be used by Tests to inject a custom MockLightningConnection.
    ///
    /// - Parameter connection: the MockLightningConnection
    internal init(connection: LightningConnection) {
        self.connection = connection
        self.kind = nil
    }

    /// When the wallet is locked on first access `RPCLightningConnection` has
    /// to be restarted to make the connection work.
    public func resetConnection() {
        guard let kind = kind else { return }
        self.connection = kind.createConnection()
    }

    // MARK: - lnd api calls

    public func info(completion: @escaping ApiCompletion<Info>) {
        connection.getInfo(Lnrpc_GetInfoRequest(), completion: map(completion, to: Info.init))
    }

    public func openChannel(pubKey: String, csvDelay: Int?, amount: Satoshi, completion: @escaping ApiCompletion<ChannelPoint>) {
        let request = Lnrpc_OpenChannelRequest(pubKey: pubKey, csvDelay: csvDelay, amount: amount)
        connection.openChannelSync(request, completion: map(completion, to: ChannelPoint.init))
    }

    public func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping ApiCompletion<CloseStatusUpdate>) {
        let request = Lnrpc_CloseChannelRequest(channelPoint: channelPoint, force: force)
        connection.closeChannel(request, completion: map(completion, to: CloseStatusUpdate.init))
    }

    public func channelBalance(completion: @escaping ApiCompletion<ChannelBalance>) {
        connection.channelBalance(Lnrpc_ChannelBalanceRequest(), completion: map(completion, to: ChannelBalance.init))
    }

    public func pendingChannels(completion: @escaping ApiCompletion<PendingChannels>) {
        connection.pendingChannels(Lnrpc_PendingChannelsRequest(), completion: map(completion, to: PendingChannels.init) )
    }

    public func channels(completion: @escaping ApiCompletion<[OpenChannel]>) {
        connection.listChannels(Lnrpc_ListChannelsRequest(), completion: map(completion) { $0.channels.map(OpenChannel.init) })
    }

    public func closedChannels(completion: @escaping ApiCompletion<[ChannelCloseSummary]>) {
        connection.closedChannels(Lnrpc_ClosedChannelsRequest(), completion: map(completion) { $0.channels.compactMap(ChannelCloseSummary.init)
        })
    }

    public func subscribeChannelEvents(completion: @escaping ApiCompletion<ChannelEventUpdate>) {
        connection.subscribeChannelEvents(Lnrpc_ChannelEventSubscription(), completion: map(completion, to: ChannelEventUpdate.init))
    }

    public func sendCoins(address: BitcoinAddress, amount: Satoshi, confirmationTarget: Int, completion: @escaping ApiCompletion<String>) {
        let request = Lnrpc_SendCoinsRequest(address: address, amount: amount, confirmationTarget: confirmationTarget)
        connection.sendCoins(request, completion: map(completion) { $0.txid })
    }

    public func transactions(completion: @escaping ApiCompletion<[Transaction]>) {
        connection.getTransactions(Lnrpc_GetTransactionsRequest(), completion: map(completion) {
            $0.transactions.map(Transaction.init)
        })
    }

    public func subscribeTransactions(completion: @escaping ApiCompletion<Transaction>) {
        connection.subscribeTransactions(Lnrpc_GetTransactionsRequest(), completion: map(completion, to: Transaction.init))
    }

    public func decodePaymentRequest(_ paymentRequest: String, completion: @escaping ApiCompletion<PaymentRequest>) {
        let request = Lnrpc_PayReqString(payReq: paymentRequest)
        connection.decodePayReq(request, completion: map(completion) { PaymentRequest(payReq: $0, raw: paymentRequest) })
    }

    public func payments(completion: @escaping ApiCompletion<[Payment]>) {
        connection.listPayments(Lnrpc_ListPaymentsRequest(), completion: map(completion) { $0.payments.map(Payment.init) })
    }

    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping ApiCompletion<Payment>) {
        let request = Lnrpc_SendRequest(paymentRequest: paymentRequest.raw, amount: amount)
        connection.sendPaymentSync(request) { result in
            switch result {
            case .success(let value):
                if !value.paymentError.isEmpty {
                    let error = LndApiError(statusMessage: value.paymentError)
                    Logger.error(error)
                    completion(.failure(error))
                } else {
                    completion(.success(Payment(paymentRequest: paymentRequest, sendResponse: value, amount: amount)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func addInvoice(amount: Satoshi?, memo: String?, expiry: ExpiryTime?, completion: @escaping ApiCompletion<String>) {
        let request = Lnrpc_Invoice(amount: amount, memo: memo, expiry: expiry)
        connection.addInvoice(request, completion: map(completion) { $0.paymentRequest })
    }

    public func invoices(completion: @escaping ApiCompletion<[Invoice]>) {
        let request = Lnrpc_ListInvoiceRequest(reversed: true)
        connection.listInvoices(request, completion: map(completion) { $0.invoices.map(Invoice.init) })
    }

    public func subscribeInvoices(completion: @escaping ApiCompletion<Invoice>) {
        connection.subscribeInvoices(Lnrpc_InvoiceSubscription(), completion: map(completion, to: Invoice.init))
    }

    public func route(destination: String, amount: Satoshi, completion: @escaping ApiCompletion<Route>) {
        let request = Lnrpc_QueryRoutesRequest(destination: destination, amount: amount)
        connection.queryRoutes(request, completion: map(completion) { $0.routes.first.map(Route.init) })
    }

    public func connect(pubKey: String, host: String, completion: @escaping ApiCompletion<Success>) {
        let request = Lnrpc_ConnectPeerRequest(pubKey: pubKey, host: host)
        connection.connectPeer(request, completion: map(completion) { _ in Success() })
    }

    public func nodeInfo(pubKey: String, completion: @escaping ApiCompletion<NodeInfo>) {
        let request = Lnrpc_NodeInfoRequest(pubKey: pubKey)
        connection.getNodeInfo(request, completion: map(completion, to: NodeInfo.init))
    }

    public func peers(completion: @escaping ApiCompletion<[Peer]>) {
        connection.listPeers(Lnrpc_ListPeersRequest(), completion: map(completion) { $0.peers.map(Peer.init) })
    }

    public func newAddress(type: OnChainRequestAddressType, completion: @escaping ApiCompletion<BitcoinAddress>) {
        let request = Lnrpc_NewAddressRequest(type: type)
        connection.newAddress(request, completion: map(completion) { BitcoinAddress(string: $0.address) })
    }

    public func walletBalance(completion: @escaping ApiCompletion<WalletBalance>) {
        connection.walletBalance(Lnrpc_WalletBalanceRequest(), completion: map(completion, to: WalletBalance.init))
    }

    public func exportAllChannelsBackup(completion: @escaping ApiCompletion<ChannelBackup>) {
        connection.exportAllChannelBackups(Lnrpc_ChanBackupExportRequest(), completion: map(completion, to: ChannelBackup.init))
    }

    public func subscribeChannelBackups(completion: @escaping ApiCompletion<ChannelBackup>) {
        connection.subscribeChannelBackups(Lnrpc_ChannelBackupSubscription(), completion: map(completion, to: ChannelBackup.init))
    }

    public func estimateFees(address: BitcoinAddress, amount: Satoshi, confirmationTarget: Int, completion: @escaping ApiCompletion<FeeEstimate>) {
        let request = Lnrpc_EstimateFeeRequest(address: address, amount: amount, confirmationTarget: confirmationTarget)
        connection.estimateFee(request, completion: map(completion, to: FeeEstimate.init))
    }
}
