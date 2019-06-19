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

    private let api: LightningApi
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

    public convenience init?(connection: LightningConnection, walletId: WalletId, backupService: StaticChannelBackupServiceType) {
        self.init(api: connection.api, walletId: walletId, connection: connection, backupService: backupService)
    }

    init(api: LightningApi, walletId: WalletId, connection: LightningConnection, backupService: StaticChannelBackupServiceType) {
        self.api = api
        self.walletId = walletId
        self.connection = connection

        let staticChannelBackupper = StaticChannelBackupper(backupService: backupService)

        let invoiceListUpdater = InvoiceListUpdater(api: api)
        let transactionListUpdater = TransactionListUpdater(api: api)
        let paymentListUpdater = PaymentListUpdater(api: api)
        let channelListUpdater = ChannelListUpdater(api: api)
        listUpdater = [invoiceListUpdater, transactionListUpdater, paymentListUpdater, channelListUpdater]

        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api, channelListUpdater: channelListUpdater, staticChannelBackupper: staticChannelBackupper)
        historyService = HistoryService(invoiceListUpdater: invoiceListUpdater, transactionListUpdater: transactionListUpdater, paymentListUpdater: paymentListUpdater, channelListUpdater: channelListUpdater)
        transactionService = TransactionService(api: api, balanceService: balanceService, paymentListUpdater: paymentListUpdater)

        infoService = InfoService(api: api, balanceService: balanceService, staticChannelBackupper: staticChannelBackupper)

        super.init()

        updateBalanceOnChange(of: invoiceListUpdater.items)
        updateBalanceOnChange(of: transactionListUpdater.items)
        updateBalanceOnChange(of: paymentListUpdater.items)
        updateBalanceOnChange(of: channelListUpdater.open)
        updateBalanceOnChange(of: channelListUpdater.closed)
        updateBalanceOnChange(of: channelListUpdater.pending)

        updateChannelsOnChange(of: invoiceListUpdater.items)
        updateChannelsOnChange(of: paymentListUpdater.items)
    }

    private func updateBalanceOnChange<T>(of items: MutableObservableArray<T>) {
        items
            .observeNext { [weak self] _ in
                self?.balanceService.update()
            }
            .dispose(in: reactive.bag)
    }

    private func updateChannelsOnChange<T>(of items: MutableObservableArray<T>) {
        items
            .observeNext { [weak self] _ in
                self?.channelService.update()
            }
            .dispose(in: reactive.bag)
    }

    public func start(completion: @escaping ApiCompletion<Success>) {
        #if !REMOTEONLY
        if connection == .local {
            if !LocalLnd.isRunning {
                LocalLnd.start(walletId: walletId)
            }
            if !WalletService.isLocalWalletUnlocked {
                WalletService(connection: connection).unlockWallet(password: WalletService.password) {
                    if case .failure(let error) = $0, error != .walletAlreadyUnlocked {
                        Logger.error(error)
                        self.stop()
                        self.infoService.walletState.value = .error
                    }
                    completion($0)
                }
            }
        }
        #endif

        infoService.start()
        listUpdater.forEach { $0.update() }
    }

    public func stop() {
        infoService.stop()
    }

    public func resetRpcConnection() {
        api.resetConnection()
    }
}
