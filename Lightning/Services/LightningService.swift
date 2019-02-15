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
    public static let receivedTransaction = Notification.Name(rawValue: "receivedTransaction")
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
    public let connectionService: ConnectionStateService
    
    var persistence: Persistence
    
    public var permissions: Permissions {
        switch connection {
        #if !REMOTEONLY
        case .local:
            return Permissions.all
        #endif
        case .remote(let connection):
            return connection.macaroon.permissions
        }
    }
    
    public convenience init?(connection: LightningConnection, walletId: WalletId) {
        let persistance = SQLitePersistence(walletId: walletId)
        self.init(api: connection.api, walletId: walletId, persistence: persistance, connection: connection)
    }
    
    init(api: LightningApiProtocol, walletId: WalletId, persistence: Persistence, connection: LightningConnection) {
        self.api = api
        self.walletId = walletId
        self.persistence = persistence
        self.connection = connection
        
        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api, persistence: persistence)
        historyService = HistoryService(api: api, channelService: channelService, persistence: persistence)
        transactionService = TransactionService(api: api, balanceService: balanceService, channelService: channelService, historyService: historyService, persistence: persistence)
        
        infoService = InfoService(api: api, channelService: channelService, balanceService: balanceService, historyService: historyService)
        
        connectionService = ConnectionStateService(infoService: infoService)
    }
    
    public func start() {
        #if !REMOTEONLY
        if connection == .local {
            LocalLnd.start(walletId: walletId)
            WalletService(connection: connection).unlockWallet { _ in }
        }
        #endif
        
        connectionService.start()
        
        api.subscribeChannelGraph { _ in }
        
        api.subscribeInvoices { [weak self] in
            guard let invoice = $0.value else { return }
            Logger.info("new invoice:\n\t\(invoice)")

            self?.historyService.addedInvoice(invoice)
            
            if invoice.state == .settled {
                NotificationCenter.default.post(name: .receivedTransaction, object: nil, userInfo: [LightningService.transactionNotificationName: invoice])
            }
        }

        api.subscribeTransactions { [weak self] in
            guard let transaction = $0.value else { return }
            Logger.info("new transaction:\n\t\(transaction)")
            self?.historyService.addedTransaction(transaction)
            self?.balanceService.update()
            
            NotificationCenter.default.post(name: .receivedTransaction, object: nil, userInfo: [LightningService.transactionNotificationName: transaction])
        }
    }
    
    public func stop() {
        #if !REMOTEONLY
        LocalLnd.stop()
        #endif
        infoService.stop()
        connectionService.stop()
    }
}
