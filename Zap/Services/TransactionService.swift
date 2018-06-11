//
//  Zap
//
//  Created by Otto Suess on 09.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class TransactionService {
    private let api: LightningProtocol
    private let balanceService: BalanceService
    private let channelService: ChannelService
    
    let transactions = Observable<[Transaction]>([])
    
    init(api: LightningProtocol, balanceService: BalanceService, channelService: ChannelService) {
        self.api = api
        self.balanceService = balanceService
        self.channelService = channelService
    }
    
    func sendCoins(address: String, amount: Satoshi, completion: @escaping () -> Void) {
        api.sendCoins(address: address, amount: amount) { _ in completion() }
    }
    
    func addInvoice(amount: Satoshi, memo: String?, callback: @escaping (Result<String>) -> Void) {
        api.addInvoice(amount: amount, memo: memo, callback: callback)
    }
    
    func newAddress(callback: @escaping (Result<String>) -> Void) {
        let type = Settings.onChainRequestAddressType.value
        api.newAddress(type: type) {
            callback($0.map {
                switch type {
                case .witnessPubkeyHash:
                    return $0.uppercased()
                case .nestedPubkeyHash:
                    return $0
                }
            })
        }
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, callback: callback)
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Bool) -> Void) {
        api.sendPayment(paymentRequest) { [weak self] result in
            if result.value != nil {
                // TODO: insert memo somewhere else
                //                if let memo = paymentRequest.memo {
                //                    transactionService.setMemo(memo, forPaymentHash: paymentRequest.paymentHash)
                //                }
                self?.update()
                self?.balanceService.update()
                self?.channelService.update()
            }
            callback(true)
        }
    }
    
    func update() {
        let taskGroup = DispatchGroup()

        var allTransactions = [Transaction]()
        
        func apiCallback(result: Result<[Transaction]>) {
            if let transactions = result.value {
                allTransactions.append(contentsOf: transactions)
            }
            taskGroup.leave()
        }
        
        taskGroup.enter()
        api.transactions(callback: apiCallback)

        taskGroup.enter()
        api.payments(callback: apiCallback)
        
        taskGroup.enter()
        api.invoices(callback: apiCallback)
        
        taskGroup.notify(queue: .main, work: DispatchWorkItem(block: { [weak self] in
            self?.transactions.value = allTransactions
        }))
    }
}
