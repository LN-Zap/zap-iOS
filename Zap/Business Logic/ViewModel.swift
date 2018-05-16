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
    
    // Transactions
    private let onChainTransactions = Observable<[Transaction]>([])
    private let payments = Observable<[Transaction]>([])
    private let invoices = Observable<[Transaction]>([])
    let transactions: Signal<[Transaction], NoError>
    
    let errorMessages = Observable<String?>(nil)

    var transactionMetadataUpdater: TransactionMetadataUpdater?
    
    init(api: LightningProtocol = LightningStream()) {
        self.api = api
        
        info = Wallet(api: api)
        balance = Balance(api: api)
        channels = Channels(api: api)
        
        transactions = combineLatest(onChainTransactions, payments, invoices) {
            return $0 as [Transaction] + $1 as [Transaction] + $2 as [Transaction]
        }

        Lnd.start()

        super.init()
        
        start()
        
        transactionMetadataUpdater = TransactionMetadataUpdater(viewModel: self, transactionMetadataStore: MemoryTransactionMetadataStore.instance)
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
        api.transactions { [onChainTransactions] result in
            onChainTransactions.value = result.value ?? []
        }
        
        api.payments { [payments] result in
            payments.value = result.value ?? []
        }

        api.invoices { [invoices] result in
            invoices.value = result.value ?? []
        }
    }
    
    func newAddress(callback: @escaping (Result<String>) -> Void) {
        api.newAddress(type: Settings.onChainRequestAddressType.value, callback: callback)
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, callback: callback)
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Bool) -> Void) {
        api.sendPayment(paymentRequest) { [weak self] _ in
            self?.balance.update()
            self?.updateTransactions()
            self?.channels.update()
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
}
