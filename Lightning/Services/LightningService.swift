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
    
    public convenience init?(connection: LndConnection) {
        guard let api = connection.api else { return nil }
        self.init(api: api)
        
        do {
            try SQLiteDataStore.shared.createTables()
            try ConnectedNodes(pubKey: "1245678", alias: "bier", color: "282828").insert()
        } catch {
            print(error)
        }
    }
    
    init(api: LightningApiProtocol) {
        self.api = api
        
        infoService = InfoService(api: api)
        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api)
        transactionService = TransactionService(api: api, balanceService: balanceService, channelService: channelService)
    }
    
    public func start() {
        infoService.walletState
            .filter { $0 != .connecting }
            .distinct()
            .observeNext { [weak self] _ in
                self?.channelService.update()
                self?.balanceService.update()
                self?.transactionService.update()
            }
            .dispose(in: reactive.bag)
        
        api.subscribeChannelGraph { _ in }
        
        api.subscribeInvoices { [weak self] _ in
            self?.transactionService.update()
        }

        api.subscribeTransactions { [weak self] _ in
            // unconfirmed transactions are not returned by GetTransactions
            self?.transactionService.update()
            self?.balanceService.update()
        }
    }
    
    public func stop() {
        LocalLnd.stop()
        infoService.stop()
    }
}
