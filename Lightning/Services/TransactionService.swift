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
    private let paymentListUpdater: PaymentListUpdater

    init(api: LightningApiProtocol, balanceService: BalanceService, paymentListUpdater: PaymentListUpdater) {
        self.api = api
        self.balanceService = balanceService
        self.paymentListUpdater = paymentListUpdater
    }

    public func addInvoice(amount: Satoshi, memo: String?, completion: @escaping (Result<String, LndApiError>) -> Void) {
        api.addInvoice(amount: amount, memo: memo, completion: completion)
    }

    public func newAddress(with type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress, LndApiError>) -> Void) {
        api.newAddress(type: type) { result in
            completion(result)
        }
    }

    internal func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest, LndApiError>) -> Void) {
        api.decodePaymentRequest(paymentRequest, completion: completion)
    }

    public func upperBoundLightningFees(for paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping (Result<(amount: Satoshi, fee: Satoshi?), LndApiError>) -> Void) {
        api.routes(destination: paymentRequest.destination, amount: amount) { result in
            let totalFees = (try? result.get())?
                .max(by: { $0.totalFees < $1.totalFees })?
                .totalFees
            completion(.success((amount: amount, fee: totalFees)))
        }
    }

    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping (Result<Success, LndApiError>) -> Void) {
        api.sendPayment(paymentRequest, amount: amount) { [balanceService, paymentListUpdater] in
            if case .success(let payment) = $0 {
                balanceService.update()
                paymentListUpdater.add(payment: payment)
            }
            completion($0.map { _ in Success() })
        }
    }

    public func sendCoins(bitcoinURI: BitcoinURI, amount: Satoshi, completion: @escaping (Result<Success, LndApiError>) -> Void) {
        let destinationAddress = bitcoinURI.bitcoinAddress
        api.sendCoins(address: destinationAddress, amount: amount) { //[historyService] in
            completion($0.map { _ in Success() })
        }
    }
}
