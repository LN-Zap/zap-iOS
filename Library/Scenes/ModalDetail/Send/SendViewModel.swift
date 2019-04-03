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

final class SendViewModel: NSObject {
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

    let subtitleText = Observable<String?>(nil)
    let isSubtitleTextWarning = Observable(false)

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

    lazy var maxPaymentAmount: Satoshi = {
        switch method {
        case .lightning:
            return min(LndConstants.maxLightningPaymentAllowed, lightningService.channelService.maxLocalBalance)
        case .onChain:
            return lightningService.balanceService.onChain.value
        }
    }()

    let receiver: String
    let memo: String?
    let isSendButtonEnabled = Observable(false)
    let isInputViewEnabled = Observable(true)

    private let lightningService: LightningService

    lazy var debounceFetchFee = {
        DispatchQueue.main.debounce(interval: 275, action: fetchLightningFee)
    }()

    init(invoice: BitcoinInvoice, lightningService: LightningService) {
        self.lightningService = lightningService

        if let paymentRequest = invoice.lightningPaymentRequest {
            method = .lightning(paymentRequest)
        } else if let bitcoinURI = invoice.bitcoinURI {
            method = .onChain(bitcoinURI)
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

        super.init()

        updateLightningFee()
        updateIsUIEnabled()
        updateSubtitle()
    }

    private func updateSubtitle() {
        Settings.shared.primaryCurrency
            .compactMap { [method, maxPaymentAmount] in
                guard let amount = $0.format(satoshis: maxPaymentAmount) else { return nil }
                switch method {
                case .lightning:
                    return L10n.Scene.Send.Subtitle.lightningCanSendBalance(amount)
                case .onChain:
                    return L10n.Scene.Send.Subtitle.onChainBalance(amount)
                }
            }
            .observeNext { [subtitleText] in
                subtitleText.value = $0
            }
            .dispose(in: reactive.bag)
    }

    private func updateIsUIEnabled() {
        isSendButtonEnabled.value = isAmountValid && !isSending
        isInputViewEnabled.value = !isSending
        isSubtitleTextWarning.value = amount ?? 0 > maxPaymentAmount
    }

    private var isAmountValid: Bool {
        guard let amount = amount else { return false }
        return amount > 0 && amount < maxPaymentAmount
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
