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
    
    var persistance = Persistance()
    
    public convenience init?(connection: LndConnection) {
        guard let api = connection.api else { return nil }
        self.init(api: api)
    }
    
    init(api: LightningApiProtocol) {
        self.api = api
        
        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api, persistance: persistance)
        historyService = HistoryService(api: api, channelService: channelService, persistance: persistance)
        transactionService = TransactionService(api: api, balanceService: balanceService, channelService: channelService, historyService: historyService)
        
        infoService = InfoService(api: api, persistance: persistance, channelService: channelService, balanceService: balanceService, historyService: historyService)
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
