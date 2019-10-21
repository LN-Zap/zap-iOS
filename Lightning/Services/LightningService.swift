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

enum LightningServiceError: Error {
    case unsupportedConfigurationError
}

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

    let listUpdaters: [ListUpdater]

    public var permissions: Permissions {
        switch connection {
        case .local:
            return Permissions.all

        case .remote(let connection):
            return connection.macaroon.permissions
        }
    }

    public convenience init(connection: LightningConnection, backupService: StaticChannelBackupServiceType) throws {
        guard let api = connection.api else { throw LightningServiceError.unsupportedConfigurationError }
        self.init(api: api, connection: connection, backupService: backupService)
    }

    init(api: LightningApi, connection: LightningConnection, backupService: StaticChannelBackupServiceType) {
        self.api = api
        self.connection = connection

        let staticChannelBackupper = StaticChannelBackupper(backupService: backupService)
        
        balanceService = BalanceService(api: api)
        
        let channelListUpdater = ChannelListUpdater(api: api, balanceService: balanceService)
        let invoiceListUpdater = InvoiceListUpdater(api: api)
        let paymentListUpdater = PaymentListUpdater(api: api)
        let transactionListUpdater = TransactionListUpdater(api: api)
        listUpdaters = [invoiceListUpdater, transactionListUpdater, paymentListUpdater, channelListUpdater]

        channelService = ChannelService(api: api, channelListUpdater: channelListUpdater, staticChannelBackupper: staticChannelBackupper)
        historyService = HistoryService(invoiceListUpdater: invoiceListUpdater, transactionListUpdater: transactionListUpdater, paymentListUpdater: paymentListUpdater, channelListUpdater: channelListUpdater)
        infoService = InfoService(api: api, balanceService: balanceService, staticChannelBackupper: staticChannelBackupper)
        transactionService = TransactionService(api: api, balanceService: balanceService, paymentListUpdater: paymentListUpdater)

        super.init()
        
        updateBalanceOnChange(of: invoiceListUpdater.items)
        updateBalanceOnChange(of: transactionListUpdater.items)
        updateBalanceOnChange(of: paymentListUpdater.items)
        updateBalanceOnChange(of: channelListUpdater.pending)
        updateBalanceOnChange(of: channelListUpdater.open)
        updateBalanceOnChange(of: channelListUpdater.closed)

        updateChannelsOnChange(of: invoiceListUpdater.items)
        updateChannelsOnChange(of: paymentListUpdater.items)
    }

    private func updateBalanceOnChange<T>(of items: MutableObservableArray<T>) {
        items
            .observeNext { [weak self] _ in
                /*
                 It looks like there is a race condition in LND where even though the transactions/invoices report back as
                 being completed, the calls to get the balances happen too quickly and the new amounts are not reported.
                 */
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { () -> Void in
                    self?.balanceService.update()
                }
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
        listUpdaters.forEach { $0.update() }
    }

    public func stop() {
        infoService.stop()
    }

    public func resetRpcConnection() {
        api.resetConnection()
    }
}
