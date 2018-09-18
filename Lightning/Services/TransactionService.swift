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
    
//    private let transactionAnnotationStore = TransactionAnnotationStore()
//    private let unconfirmedTransactionStore = UnconfirmedTransactionStore()
    
//    public let transactions = Observable<[Transaction]>([])
    
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
        api.transactions { result in
            if let transactions = result.value {
                let events = transactions.map { TransactionEvent(transaction: $0) } // todo: don't
                DatabaseUpdater.addTransactions(events)
            }
        }
        
        api.payments {
            guard let payments = $0.value else { return }
            DatabaseUpdater.addPayments(payments)
        }
        
        api.invoices {
            guard let invoices = $0.value else { return }
            DatabaseUpdater.addInvoices(invoices)
        }
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
                
//                if let memo = paymentRequest.memo {
//                    self?.udpateMemo(memo, forTransactionId: transaction.id)
//                }
            }
            completion($0.map { _ in Success() })
        }
    }
    
    private func sendCoins(bitcoinURI: BitcoinURI, amount: Satoshi, completion: @escaping (Result<Success>) -> Void) {
        let destinationAddress = bitcoinURI.bitcoinAddress
        api.sendCoins(address: destinationAddress, amount: amount) { [weak self] in
            if let txid = $0.value {                
                DatabaseUpdater.addUnconfirmedTransaction(txId: txid, amount: amount, memo: bitcoinURI.memo, destinationAddress: destinationAddress)
                
//                let unconfirmedTransaction = OnChainUnconfirmedTransaction(id: txid, amount: -amount, date: Date(), destinationAddresses: [destinationAddress])
//                self?.unconfirmedTransactionStore.add(unconfirmedTransaction)
//                self?.transactions.value.append(unconfirmedTransaction)
                
//                if let memo = bitcoinURI.memo {
//                    self?.udpateMemo(memo, forTransactionId: unconfirmedTransaction.id)
//                }
            }
            completion($0.map { _ in Success() })
        }
    }
}
