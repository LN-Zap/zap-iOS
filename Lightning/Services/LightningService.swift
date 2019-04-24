//
//  Zap
//
//  Created by Otto Suess on 21.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import Logger
import ReactiveKit
import SwiftBTC
import SwiftLnd

public extension Notification.Name {
    static let receivedTransaction = Notification.Name(rawValue: "receivedTransaction")
}

public final class LightningService: NSObject {
    public static var transactionNotificationName = "transactionNotificationName"

    private let api: LightningApiProtocol
    private let walletId: WalletId
    public let connection: LightningConnection

    public let infoService: InfoService
    public let balanceService: BalanceService
    public let channelService: ChannelService
    public let transactionService: TransactionService
    public let historyService: HistoryService

    let listUpdater: [ListUpdater]

    public var permissions: Permissions {
        switch connection {
        case .local:
            return Permissions.all
        case .remote(let connection):
            return connection.macaroon.permissions
        }
    }

    public convenience init?(connection: LightningConnection, walletId: WalletId) {
        self.init(api: connection.api, walletId: walletId, connection: connection)
    }

    init(api: LightningApiProtocol, walletId: WalletId, connection: LightningConnection) {
        self.api = api
        self.walletId = walletId
        self.connection = connection

        let invoiceListUpdater = InvoiceListUpdater(api: api)
        let transactionListUpdater = TransactionListUpdater(api: api)
        let paymentListUpdater = PaymentListUpdater(api: api)
        let channelListUpdater = ChannelListUpdater(api: api)
        listUpdater = [invoiceListUpdater, transactionListUpdater, paymentListUpdater, channelListUpdater]

        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api, channelListUpdater: channelListUpdater)
        historyService = HistoryService(invoiceListUpdater: invoiceListUpdater, transactionListUpdater: transactionListUpdater, paymentListUpdater: paymentListUpdater, channelListUpdater: channelListUpdater)
        transactionService = TransactionService(api: api, balanceService: balanceService, paymentListUpdater: paymentListUpdater)

        infoService = InfoService(api: api, balanceService: balanceService)
    }

    public func start() {
        #if !REMOTEONLY
        if connection == .local {
            LocalLnd.start(walletId: walletId)
            WalletService(connection: connection).unlockWallet(password: WalletService.password) { _ in }
        }
        #endif

        listUpdater.forEach { $0.update() }
    }

    public func stop() {
        infoService.stop()
    }

    public func resetRpcConnection() {
        guard let api = api as? RpcApi else { return }
        api.resetConnection()
    }
}
