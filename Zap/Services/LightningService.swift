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

final class LightningService: NSObject {
    private let api: LightningProtocol
    
    let infoService: InfoService
    let balanceService: BalanceService
    let channelService: ChannelService
    let transactionService: TransactionService
    
//    var channelTransactionAnnotationUpdater: ChannelTransactionAnnotationUpdater?
    
    init(api: LightningProtocol) {
        self.api = api
        
        infoService = InfoService(api: api)
        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api)
        transactionService = TransactionService(api: api, balanceService: balanceService, channelService: channelService)
            
//        super.init()

//        channelTransactionAnnotationUpdater = ChannelTransactionAnnotationUpdater(viewModel: self, transactionStore: transactionService)
    }
    
    func start() {
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
        }
    }
    
    func stop() {
        infoService.stop()
    }
}


