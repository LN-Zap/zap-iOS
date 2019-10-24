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

    public func addInvoice(amount: Satoshi, memo: String?, expiry: ExpiryTime?, completion: @escaping ApiCompletion<String>) {
        api.addInvoice(amount: amount, memo: memo, expiry: expiry, completion: completion)
    }

    public func newAddress(with type: OnChainRequestAddressType, completion: @escaping ApiCompletion<BitcoinAddress>) {
        api.newAddress(type: type) { result in
            completion(result)
        }
    }

    internal func decodePaymentRequest(_ paymentRequest: String, completion: @escaping ApiCompletion<PaymentRequest>) {
        api.decodePaymentRequest(paymentRequest, completion: completion)
    }

    /// Fee methods can be called multiple times at once. So the completion
    /// includes amount to match on the caller side that the returned result is
    /// for the correct amount.
    public typealias FeeApiCompletion = (Result<(amount: Satoshi, fee: Satoshi?), LndApiError>) -> Void

    public func lightningFees(for paymentRequest: PaymentRequest, amount: Satoshi, completion: @escaping FeeApiCompletion) {
        api.route(destination: paymentRequest.destination, amount: amount) { result in
            let totalFees = (try? result.get())?.totalFees
            completion(.success((amount: amount, fee: totalFees)))
        }
    }

    public func onChainFees(address: BitcoinAddress, amount: Satoshi, confirmationTarget: Int, completion: @escaping FeeApiCompletion) {
        api.estimateFees(address: address, amount: amount, confirmationTarget: confirmationTarget) { result in
            switch result {
            case .success(let feeEstimate):
                completion(.success((amount: amount, fee: feeEstimate.total)))
            case .failure(let lndApiError):
                completion(.failure(lndApiError))
            }
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

    public func sendCoins(bitcoinURI: BitcoinURI, amount: Satoshi, confirmationTarget: Int, completion: @escaping ApiCompletion<Success>) {
        let destinationAddress = bitcoinURI.bitcoinAddress
        api.sendCoins(address: destinationAddress, amount: amount, confirmationTarget: confirmationTarget) {
            completion($0.map { _ in Success() })
        }
    }
}
