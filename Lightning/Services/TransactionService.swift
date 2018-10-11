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
    private let historyService: HistoryService
    private let persistence: Persistence

    init(api: LightningApiProtocol, balanceService: BalanceService, channelService: ChannelService, historyService: HistoryService, persistence: Persistence) {
        self.api = api
        self.balanceService = balanceService
        self.channelService = channelService
        self.historyService = historyService
        self.persistence = persistence
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
        api.addInvoice(amount: amount, memo: memo, completion: completion)
    }
    
    public func newAddress(with type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void) {
        api.newAddress(type: type) { [persistence] result in
            if let address = result.value {
                try? ReceivingAddress.insert(address: address, database: persistence.connection())
            }
            completion(result)
        }
    }
    
    internal func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, completion: completion)
    }
    
    private func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping (Result<Success>) -> Void) {
        api.sendPayment(paymentRequest, amount: amount) { [weak self] in
            
            switch $0 {
            case .success(let payment):
                self?.balanceService.update()
                self?.channelService.update()
                self?.historyService.addPaymentEvent(payment: payment, memo: paymentRequest.memo)
            case .failure:
                self?.historyService.addFailedPaymentEvent(paymentRequest: paymentRequest, amount: amount)
            }

            completion($0.map { _ in Success() })
        }
    }
    
    private func sendCoins(bitcoinURI: BitcoinURI, amount: Satoshi, completion: @escaping (Result<Success>) -> Void) {
        let destinationAddress = bitcoinURI.bitcoinAddress
        api.sendCoins(address: destinationAddress, amount: amount) { [historyService] in
            if case .success(let txHash) = $0 {
                let transactionEvent = TransactionEvent(txHash: txHash, bitcoinURI: bitcoinURI, amount: -amount)
                historyService.updateTransactionEventMetadata(transactionEvent: transactionEvent)
            }
            completion($0.map { _ in Success() })
        }
    }
}
