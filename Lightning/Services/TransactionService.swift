//
//  Zap
//
//  Created by Otto Suess on 09.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import SwiftLnd

public final class TransactionService {
    private let api: LightningApiProtocol
    private let balanceService: BalanceService
    private let channelService: ChannelService
    
    private let transactionAnnotationStore = TransactionAnnotationStore()
    private let unconfirmedTransactionStore = UnconfirmedTransactionStore()
    
    public let transactions = Observable<[Transaction]>([])
    
    init(api: LightningApiProtocol, balanceService: BalanceService, channelService: ChannelService) {
        self.api = api
        self.balanceService = balanceService
        self.channelService = channelService
    }
    
    public func send(_ invoice: BitcoinInvoice, amount: Satoshi, completion: @escaping (Result<Success>) -> Void) {
        if let paymentRequest = invoice.lightningPaymentRequest {
            sendPayment(paymentRequest, amount: amount, completion: completion)
        } else if let bitcoinURI = invoice.bitcoinURI {
            sendCoins(bitcoinURI: bitcoinURI, amount: amount, completion: completion)
        } else {
            fatalError("There should not be an invoice without either a paymentRequest or bitcoinURI")
        }
    }
    
    public func addInvoice(amount: Satoshi, memo: String?, completion: @escaping (Result<String>) -> Void) {
        api.addInvoice(amount: amount, memo: memo) { [weak self] in
            if $0.value != nil {
                self?.update()
            }
            completion($0)
        }
    }
    
    public func newAddress(with type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        api.newAddress(type: type, completion: completion)
    }
    
    public func update() {
        let taskGroup = DispatchGroup()
        
        var allTransactions = [Transaction]()
        
        func apiCallback(result: Result<[Transaction]>) {
            if let transactions = result.value {
                allTransactions.append(contentsOf: transactions)
            }
            taskGroup.leave()
        }
        
        taskGroup.enter()
        api.transactions { result in
            if let transactions = result.value {
                let events = transactions.map { OnChainPaymentEvent(transaction: $0) }
                DatabaseUpdater.addTransactions(events)
            }
            apiCallback(result: result.map({ $0 as [Transaction] }))
        }
        
        taskGroup.enter()
        api.payments { apiCallback(result: $0.map({ $0 as [Transaction] })) }
        
        taskGroup.enter()
        api.invoices { apiCallback(result: $0.map({ $0 as [Transaction] })) }
        
        taskGroup.notify(queue: .main, work: DispatchWorkItem(block: { [weak self] in
            self?.unconfirmedTransactionStore.remove(confirmed: allTransactions)
            if let unconfirmed = self?.unconfirmedTransactionStore.all {
                allTransactions.append(contentsOf: unconfirmed)
            }
            self?.transactions.value = allTransactions
        }))
    }
    
    internal func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, completion: completion)
    }
    
    private func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping (Result<Success>) -> Void) {
        api.sendPayment(paymentRequest, amount: amount) { [weak self] in
            if case .success(let transaction) = $0 {
                self?.update()
                self?.balanceService.update()
                self?.channelService.update()
                
                if let memo = paymentRequest.memo {
                    self?.udpateMemo(memo, forTransactionId: transaction.id)
                }
            }
            completion($0.map { _ in Success() })
        }
    }
    
    private func sendCoins(bitcoinURI: BitcoinURI, amount: Satoshi, completion: @escaping (Result<Success>) -> Void) {
        let destinationAddress = bitcoinURI.bitcoinAddress
        api.sendCoins(address: destinationAddress, amount: amount) { [weak self] in
            if let txid = $0.value {                
                DatabaseUpdater.addUnconfirmedTransaction(txId: txid, amount: amount, memo: bitcoinURI.memo, destinationAddress: destinationAddress)
                
                let unconfirmedTransaction = OnChainUnconfirmedTransaction(id: txid, amount: -amount, date: Date(), destinationAddresses: [destinationAddress])
                self?.unconfirmedTransactionStore.add(unconfirmedTransaction)
                self?.transactions.value.append(unconfirmedTransaction)
                
                if let memo = bitcoinURI.memo {
                    self?.udpateMemo(memo, forTransactionId: unconfirmedTransaction.id)
                }
            }
            completion($0.map { _ in Success() })
        }
    }
    
    // annotations
    
    public func annotation(for transaction: Transaction) -> TransactionAnnotation {
        return transactionAnnotationStore.annotation(for: transaction)
    }
    
    public func updateAnnotation(_ annotation: TransactionAnnotation, for transaction: Transaction) {
        transactionAnnotationStore.updateAnnotation(annotation, for: transaction)
    }
    
    public func setTransactionHidden(_ transaction: Transaction, hidden: Bool) -> TransactionAnnotation {
        return transactionAnnotationStore.setTransactionHidden(transaction, hidden: hidden)
    }
    
    public func udpateMemo(_ memo: String?, forTransactionId transactionId: String) {
        return transactionAnnotationStore.udpateMemo(memo, forTransactionId: transactionId)
    }
}
