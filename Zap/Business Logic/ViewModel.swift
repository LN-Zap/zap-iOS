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

final class ViewModel: NSObject {
    private let api: LightningProtocol
    
    let info: Wallet
    let balance: Balance
    let channels: Channels
    private let transactionStore = TransactionStore()
    
    // Transactions
    private let onChainTransactions = Observable<[Transaction]>([])
    private let payments = Observable<[Transaction]>([])
    private let invoices = Observable<[Transaction]>([])
    var transactions: Observable<[TransactionViewModel]> {
        return transactionStore.transactions
    }
    
    let errorMessages = Observable<String?>(nil)

    var channelTransactionAnnotationUpdater: ChannelTransactionAnnotationUpdater?
    
    init(api: LightningProtocol) {
        self.api = api
        
        info = Wallet(api: api)
        balance = Balance(api: api)
        channels = Channels(api: api)
            
        super.init()

        channelTransactionAnnotationUpdater = ChannelTransactionAnnotationUpdater(viewModel: self, transactionStore: transactionStore)

        start()
    }
    
    private func start() {
        info.walletState
            .filter { $0 != .connecting }
            .distinct()
            .observeNext { [weak self] _ in
                self?.channels.update()
                self?.balance.update()
                self?.updateTransactions()
            }
            .dispose(in: reactive.bag)
        
        api.subscribeChannelGraph { _ in

        }
    }
    
    func updateTransactions() {
        func callback(result: Result<[Transaction]>) {
            guard let transactions = result.value else { return }
            transactionStore.update(transactions: transactions)
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
        api.sendPayment(paymentRequest) { [weak self, transactionStore] result in
            if result.value != nil {
                if let memo = paymentRequest.memo {
                    transactionStore.setMemo(memo, forPaymentHash: paymentRequest.paymentHash)
                }
                self?.balance.update()
                self?.updateTransactions()
                self?.channels.update()
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
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        api.nodeInfo(pubKey: pubKey, callback: callback)
    }
    
    // TODO: refactor - move this somewhere else
    
    func hideTransaction(_ transactionViewModel: TransactionViewModel) {
        let newAnnotation = TransactionAnnotation.lens.isHidden.set(true, transactionViewModel.annotation.value)
        transactionStore.updateAnnotation(newAnnotation, for: transactionViewModel)
    }
    
    func udpateMemo(_ memo: String?, for transactionViewModel: TransactionViewModel) {
        var memo = memo
        if memo == "" {
            memo = nil
        }
        
        let newAnnotation = TransactionAnnotation.lens.customMemo.set(memo, transactionViewModel.annotation.value)
        transactionStore.updateAnnotation(newAnnotation, for: transactionViewModel)
    }
}
