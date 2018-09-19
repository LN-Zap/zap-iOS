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
    
    public convenience init?(connection: LndConnection) {
        guard let api = connection.api else { return nil }
        self.init(api: api)
    }
    
    init(api: LightningApiProtocol) {
        self.api = api
        
        infoService = InfoService(api: api)
        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api)
        historyService = HistoryService(api: api, channelService: channelService)
        transactionService = TransactionService(api: api, balanceService: balanceService, channelService: channelService, historyService: historyService)
    }
    
    public func start() {
        infoService.walletState
            .filter { $0 != .connecting }
            .distinct()
            .observeNext { [weak self] _ in
                self?.channelService.update()
                self?.balanceService.update()
                self?.historyService.update()
            }
            .dispose(in: reactive.bag)
        
        api.subscribeChannelGraph { _ in }
        
        api.subscribeInvoices { [weak self] in
            guard let invoice = $0.value else { return }
            self?.historyService.addedInvoice(invoice)
        }

        api.subscribeTransactions { [weak self] in
            guard let transaction = $0.value else { return }
            self?.historyService.addedTransaction(transaction)
            self?.balanceService.update()
        }
    }
    
    public func stop() {
        LocalLnd.stop()
        infoService.stop()
    }
}
