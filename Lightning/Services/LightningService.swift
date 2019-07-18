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

    public convenience init?(connection: LightningConnection, backupService: StaticChannelBackupServiceType) {
        self.init(api: connection.api, connection: connection, backupService: backupService)
    }

    init(api: LightningApi, connection: LightningConnection, backupService: StaticChannelBackupServiceType) {
        self.api = api
        self.connection = connection

        NotificationScheduler.shared.requestAuthorization()

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

        if connection == .local {
            // schedule reminder notifications
            combineLatest(channelListUpdater.open, channelListUpdater.pending, infoService.bestHeaderDate) { ($0.collection + $1.collection, $2) }
                .debounce(interval: 2)
                .observeNext { NotificationScheduler.shared.schedule(for: $0.0, bestHeaderDate: $0.1) }
                .dispose(in: reactive.bag)
        }
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

    public func startLocalWallet(network: Network, password: String, completion: @escaping ApiCompletion<Success>) {
        #if !REMOTEONLY
        guard
            connection == .local,
            !WalletService.isLocalWalletUnlocked
            else { return }

        LocalLnd.start(network: network)
        WalletService(connection: connection).unlockWallet(password: password) {
            if case .failure(let error) = $0, error != .walletAlreadyUnlocked {
                Logger.error(error)
                self.stop()
                self.infoService.walletState.value = .error
            }
            completion($0)
        }
        #endif
    }

    public func start() {
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
