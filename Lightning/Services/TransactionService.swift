//
//  Zap
//
//  Created by Otto Suess on 09.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftBTC
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
    
    public func addInvoice(amount: Satoshi, memo: String?, completion: @escaping (Result<String, LndApiError>) -> Void) {
        api.addInvoice(amount: amount, memo: memo, completion: completion)
    }
    
    public func newAddress(with type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress, LndApiError>) -> Void) {
        api.newAddress(type: type) { [persistence] result in
            if let address = result.value {
                try? ReceivingAddress.insert(address: address, database: persistence.connection())
            }
            completion(result)
        }
    }
    
    internal func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest, LndApiError>) -> Void) {
        api.decodePaymentRequest(paymentRequest, completion: completion)
    }
    
    public func upperBoundLightningFees(for paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping (Result<(amount: Satoshi, fee: Satoshi?), LndApiError>) -> Void) {
        api.routes(destination: paymentRequest.destination, amount: amount) { result in
            let totalFees = result.value?
                .max(by: { $0.totalFees < $1.totalFees })?
                .totalFees
            completion(.success((amount: amount, fee: totalFees)))
        }
    }
    
    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping (Result<Success, LndApiError>) -> Void) {
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
    
    public func sendCoins(bitcoinURI: BitcoinURI, amount: Satoshi, completion: @escaping (Result<Success, LndApiError>) -> Void) {
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

struct LightningPayment {
    let paymentRequest: PaymentRequest
    let routes: [Route]
}
