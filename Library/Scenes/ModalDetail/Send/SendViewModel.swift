//
//  Library
//
//  Created by Otto Suess on 18.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

extension InvoiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownFormat:
            return L10n.Error.wrongUriFormat
        case let .wrongNetworkError(linkNetwork, expectedNetwork):
            return L10n.Error.wrongUriNetwork(linkNetwork.localized, expectedNetwork.localized)
        case .apiError(let localizedDescription):
            return localizedDescription
        }
    }
}

final class SendViewModel {

    enum Constants {
        fileprivate static let minimumOnChainTransaction: Satoshi = 547
    }

    enum SendMethod {
        case lightning(PaymentRequest)
        case onChain(BitcoinURI)

        var headerImage: UIImage {
            switch self {
            case .lightning:
                return Asset.iconHeaderLightning.image
            case .onChain:
                return Asset.iconHeaderOnChain.image
            }
        }

        var headline: String {
            switch self {
            case .lightning:
                return L10n.Scene.Send.Lightning.title
            case .onChain:
                return L10n.Scene.Send.OnChain.title
            }
        }
    }

    let lightningFee = Observable<Loadable<Satoshi?>>(.loading)
    let method: SendMethod

    var amount: Satoshi? {
        didSet {
            guard oldValue != amount else { return }
            updateLightningFee()
            updateIsUIEnabled()
        }
    }
    var isSending = false {
        didSet {
            updateIsUIEnabled()
        }
    }

    let receiver: String
    let memo: String?
    let isSendButtonEnabled = Observable(false)
    let isInputViewEnabled = Observable(true)

    let validRange: ClosedRange<Satoshi>?

    private let lightningService: LightningService

    lazy var debounceFetchFee = {
        DispatchQueue.main.debounce(interval: 275, action: fetchLightningFee)
    }()

    init(invoice: BitcoinInvoice, lightningService: LightningService) {
        self.lightningService = lightningService

        if let paymentRequest = invoice.lightningPaymentRequest {
            method = .lightning(paymentRequest)

            validRange = 1...LndConstants.maxLightningPaymentAllowed
        } else if let bitcoinURI = invoice.bitcoinURI {
            method = .onChain(bitcoinURI)

            if lightningService.balanceService.onChain.value == 0 {
                validRange = nil
            } else {
                validRange = Constants.minimumOnChainTransaction...lightningService.balanceService.onChain.value
            }
        } else {
            fatalError("Invalid Invoice")
        }

        receiver = invoice.lightningPaymentRequest?.destination ?? invoice.bitcoinURI?.address ?? "-"
        if
            let amount = invoice.lightningPaymentRequest?.amount ?? invoice.bitcoinURI?.amount,
            amount > 0 {
            self.amount = amount
        }
        memo = invoice.lightningPaymentRequest?.memo ?? invoice.bitcoinURI?.memo

        updateLightningFee()
        updateIsUIEnabled()
    }

    private func updateIsUIEnabled() {
        isSendButtonEnabled.value = isAmountValid && !isSending
        isInputViewEnabled.value = !isSending
    }

    private var isAmountValid: Bool {
        guard
            let amount = amount,
            let validRange = validRange
            else { return false }
        return validRange.contains(amount)
    }

    private func updateLightningFee() {
        guard case .lightning = method else { return }

        if isAmountValid {
            lightningFee.value = .loading
            updateIsUIEnabled()
            debounceFetchFee()
        } else {
            lightningFee.value = .element(nil)
        }
    }

    private func fetchLightningFee() {
        guard
            case .lightning(let paymentRequest) = method,
            let amount = amount
            else { return }

        lightningService.transactionService.upperBoundLightningFees(for: paymentRequest, amount: amount) { [weak self] in
            guard let self = self, (try? $0.get())?.amount == self.amount else { return }
            self.lightningFee.value = .element((try? $0.get())?.fee)
            self.updateIsUIEnabled()
        }
    }

    func send(completion: @escaping (Result<Success, LndApiError>) -> Void) {
        guard let amount = amount else { return }

        isSending = true

        let internalComplection: (Result<Success, LndApiError>) -> Void = { [weak self] in
            if case .failure = $0 {
                self?.isSending = false
            }
            completion($0)
        }

        switch method {
        case .lightning(let paymentRequest):
            lightningService.transactionService.sendPayment(paymentRequest, amount: amount, completion: internalComplection)
        case .onChain(let bitcoinURI):
            lightningService.transactionService.sendCoins(bitcoinURI: bitcoinURI, amount: amount, completion: internalComplection)
        }
    }
}
