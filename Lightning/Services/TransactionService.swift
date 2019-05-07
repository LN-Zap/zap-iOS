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
    private let api: LightningApi
    private let balanceService: BalanceService
    private let paymentListUpdater: PaymentListUpdater

    init(api: LightningApi, balanceService: BalanceService, paymentListUpdater: PaymentListUpdater) {
        self.api = api
        self.balanceService = balanceService
        self.paymentListUpdater = paymentListUpdater
    }

    public func addInvoice(amount: Satoshi, memo: String?, completion: @escaping ApiCompletion<String>) {
        api.addInvoice(amount: amount, memo: memo, completion: completion)
    }

    public func newAddress(with type: OnChainRequestAddressType, completion: @escaping ApiCompletion<BitcoinAddress>) {
        api.newAddress(type: type) { result in
            completion(result)
        }
    }

    internal func decodePaymentRequest(_ paymentRequest: String, completion: @escaping ApiCompletion<PaymentRequest>) {
        api.decodePaymentRequest(paymentRequest, completion: completion)
    }

    public func upperBoundLightningFees(for paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping ApiCompletion<(amount: Satoshi, fee: Satoshi?)>) {
        api.routes(destination: paymentRequest.destination, amount: amount) { result in
            let totalFees = (try? result.get())?
                .max(by: { $0.totalFees < $1.totalFees })?
                .totalFees
            completion(.success((amount: amount, fee: totalFees)))
        }
    }

    public func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping ApiCompletion<Success>) {
        api.sendPayment(paymentRequest, amount: amount) { [balanceService, paymentListUpdater] in
            if case .success(let payment) = $0 {
                balanceService.update()
                paymentListUpdater.add(payment: payment)
            }
            completion($0.map { _ in Success() })
        }
    }

    public func sendCoins(bitcoinURI: BitcoinURI, amount: Satoshi, completion: @escaping ApiCompletion<Success>) {
        let destinationAddress = bitcoinURI.bitcoinAddress
        api.sendCoins(address: destinationAddress, amount: amount) { //[historyService] in
            completion($0.map { _ in Success() })
        }
    }
}
