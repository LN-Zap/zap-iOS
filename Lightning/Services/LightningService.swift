//
//  Zap
//
//  Created by Otto Suess on 21.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit
import SwiftLnd

public final class LightningService: NSObject {
    private let api: LightningApiProtocol
    
    public let infoService: InfoService
    public let balanceService: BalanceService
    public let channelService: ChannelService
    public let transactionService: TransactionService
    public let historyService: HistoryService
    
    var persistence: Persistence
    
    public convenience init?(connection: LightningConnection) {
        guard let api = connection.start() else { return nil }
        self.init(api: api, persistence: SQLitePersistence())
    }
    
    init(api: LightningApiProtocol, persistence: Persistence) {
        self.api = api
        self.persistence = persistence
        
        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api, persistence: persistence)
        historyService = HistoryService(api: api, channelService: channelService, persistence: persistence)
        transactionService = TransactionService(api: api, balanceService: balanceService, channelService: channelService, historyService: historyService, persistence: persistence)
        
        infoService = InfoService(api: api, persistence: persistence, channelService: channelService, balanceService: balanceService, historyService: historyService)
    }
    
    public func start() {
        api.subscribeChannelGraph { _ in }
        
        api.subscribeInvoices { [weak self] in
            guard let invoice = $0.value else { return }
            print("🛍 new invoice:\n\t\(invoice)")
            self?.historyService.addedInvoice(invoice)
        }

        api.subscribeTransactions { [weak self] in
            guard let transaction = $0.value else { return }
            print("💵 new transaction:\n\t\(transaction)")
            self?.historyService.addedTransaction(transaction)
            self?.balanceService.update()
        }
    }
    
    public func stop() {
        LocalLnd.stop()
        infoService.stop()
    }
}
