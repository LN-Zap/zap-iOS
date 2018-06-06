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
    
    // TODO: move stores somewhere else, why is there no transaction Service?
    let transactionService: TransactionStore
    let aliasStore: ChannelAliasStore
    
    var channelTransactionAnnotationUpdater: ChannelTransactionAnnotationUpdater?
    
    init(api: LightningProtocol) {
        self.api = api
        
        infoService = InfoService(api: api)
        balanceService = BalanceService(api: api)
        channelService = ChannelService(api: api)
        aliasStore = ChannelAliasStore(api: api)
        transactionService = TransactionStore(aliasStore: aliasStore)
        
        super.init()

        channelTransactionAnnotationUpdater = ChannelTransactionAnnotationUpdater(viewModel: self, transactionStore: transactionService)

        start()
    }
    
    private func start() {
        infoService.walletState
            .filter { $0 != .connecting }
            .distinct()
            .observeNext { [weak self] _ in
                self?.channelService.update()
                self?.balanceService.update()
                self?.updateTransactions()
            }
            .dispose(in: reactive.bag)
        
//        api.subscribeChannelGraph { _ in }
        
        api.subscribeInvoices { [weak self] _ in
            self?.updateTransactions()
        }
        
        api.subscribeTransactions { [weak self] _ in
            // unconfirmed transactions are not returned by GetTransactions
            self?.updateTransactions()
        }
    }
    
    func updateTransactions() {
        func callback(result: Result<[Transaction]>) {
            guard let transactions = result.value else { return }
            transactionService.update(transactions: transactions)
        }
        
        api.transactions(callback: callback)
        api.payments(callback: callback)
        api.invoices(callback: callback)
    }
    
    func newAddress(callback: @escaping (Result<String>) -> Void) {
        api.newAddress(type: Settings.onChainRequestAddressType.value, callback: callback)
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, callback: callback)
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Bool) -> Void) {
        api.sendPayment(paymentRequest) { [weak self, transactionService] result in
            if result.value != nil {
                if let memo = paymentRequest.memo {
                    transactionService.setMemo(memo, forPaymentHash: paymentRequest.paymentHash)
                }
                self?.balanceService.update()
                self?.updateTransactions()
                self?.channelService.update()
            }
            callback(true)
        }
    }
    
    func sendCoins(address: String, amount: Satoshi, completion: @escaping () -> Void) {
        api.sendCoins(address: address, amount: amount) { _ in completion() }
    }
    
    func addInvoice(amount: Satoshi, memo: String?, callback: @escaping (Result<String>) -> Void) {
        api.addInvoice(amount: amount, memo: memo, callback: callback)
    }
    
    func stop() {
        infoService.stop()
    }
        
    // TODO: refactor - move this somewhere else
    
    func hideTransaction(_ transactionViewModel: TransactionViewModel) {
        let newAnnotation = TransactionAnnotation.lens.isHidden.set(true, transactionViewModel.annotation.value)
        transactionService.updateAnnotation(newAnnotation, for: transactionViewModel)
    }
    
    func udpateMemo(_ memo: String?, for transactionViewModel: TransactionViewModel) {
        var memo = memo
        if memo == "" {
            memo = nil
        }
        
        let newAnnotation = TransactionAnnotation.lens.customMemo.set(memo, transactionViewModel.annotation.value)
        transactionService.updateAnnotation(newAnnotation, for: transactionViewModel)
    }
}
