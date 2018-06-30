//
//  Zap
//
//  Created by Otto Suess on 09.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

public final class TransactionService {
    private let api: LightningApiProtocol
    private let balanceService: BalanceService
    private let channelService: ChannelService
    
    public let transactions = Observable<[Transaction]>([])
    
    init(api: LightningApiProtocol, balanceService: BalanceService, channelService: ChannelService) {
        self.api = api
        self.balanceService = balanceService
        self.channelService = channelService
    }
    
    public func sendCoins(address: String, amount: Satoshi, completion: @escaping () -> Void) {
        api.sendCoins(address: address, amount: amount) { _ in completion() }
    }
    
    public func addInvoice(amount: Satoshi, memo: String?, callback: @escaping (Result<String>) -> Void) {
        api.addInvoice(amount: amount, memo: memo, callback: callback)
    }
    
    public func newAddress(with type: OnChainRequestAddressType, callback: @escaping (Result<String>) -> Void) {
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
    
    public func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, callback: callback)
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Bool) -> Void) {
        api.sendPayment(paymentRequest) { [weak self] result in
            if result.value != nil {
                self?.update()
                self?.balanceService.update()
                self?.channelService.update()
            }
            callback(true)
        }
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
