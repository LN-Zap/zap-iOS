//
//  Library
//
//  Created by Otto Suess on 18.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit
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
    
    struct FeeInfo {
        var feePercentage: Decimal
        var userFeeLimitPercentage: Int
        var sendFeeLimitPercentage: Int?
    }
    
    enum SendError: Error {
        case feeGreaterThanPayment(FeeInfo)
        case feePercentageGreaterThanUserLimit(FeeInfo)
    }

    let paymentFeeThreshold: Satoshi = 100
    let fee = Observable<Loadable<Result<Satoshi, LoadingError>>>(.loading)
    let method: SendMethod
    let subtitleText = Observable<String?>(nil)
    let isSubtitleTextWarning = Observable(false)
    let sendStatus = Subject<Int?, SendError>()
    
    var feePercent: Decimal?

    var amount: Satoshi? {
        didSet {
            guard oldValue != amount else { return }
            updateFee()
            updateSubtitle()
            updateIsUIEnabled()
        }
    }

    var confirmationTarget: Int = 0 {
        didSet {
            updateFee()
        }
    }
    
    var isTransactionDust = false {
        didSet {
            updateIsUIEnabled()
            updateSubtitle()
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
            return lightningService.balanceService.onChainConfirmed.value
        }
    }()

    let receiver: String
    let memo: String?
    let isSendButtonEnabled = Observable(false)
    let isInputViewEnabled = Observable(true)

    private let lightningService: LightningService

    lazy var debounceFetchFee = {
        DispatchQueue.main.debounce(interval: 275, action: fetchFee)
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

        updateFee()
        updateIsUIEnabled()
        setupPrimaryCurrencyListener()
    }

    func send(feeLimitPercent: Int?, completion: @escaping ApiCompletion<Success>) {
        guard let amount = amount else { return }

        isSending = true

        let internalComplection: ApiCompletion<Success> = { [weak self] in
            if case .failure = $0 {
                self?.isSending = false
            }
            completion($0)
        }
        
        switch method {
        case .lightning(let paymentRequest):
            lightningService.transactionService.sendPayment(paymentRequest, amount: amount, feeLimitPercent: feeLimitPercent, completion: internalComplection)
        case .onChain(let bitcoinURI):
            lightningService.transactionService.sendCoins(bitcoinURI: bitcoinURI, amount: amount, confirmationTarget: confirmationTarget, completion: internalComplection)
        }
    }
    
    func determineSendStatus() {
        switch method {
        case .lightning:
            self.determineLightningSendStatus()
        default:
            self.sendStatus.receive(nil)
        }
    }
    
    private func determineLightningSendStatus() {
        guard let amount = amount, let feePercent = feePercent else { return }
        
        let actualFee: Satoshi
        
        switch fee.value {
        case .element(let fee):
            switch fee {
            case .success(let fee):
                actualFee = fee
            default:
                return
            }
        default:
            return
        }
        
        if amount <= paymentFeeThreshold {
            if actualFee >= amount {
                self.sendStatus.receive(event: .failed(.feeGreaterThanPayment(FeeInfo(feePercentage: feePercent, userFeeLimitPercentage: Settings.shared.lightningPaymentFeeLimit.value.rawValue, sendFeeLimitPercentage: nil))))
            } else {
                self.sendStatus.receive(100)
            }
        } else if actualFee >= amount {
            self.sendStatus.receive(event: .failed(.feeGreaterThanPayment(FeeInfo(feePercentage: feePercent, userFeeLimitPercentage: Settings.shared.lightningPaymentFeeLimit.value.rawValue, sendFeeLimitPercentage: nil))))
        } else if Settings.shared.lightningPaymentFeeLimit.value == .none {
            self.sendStatus.receive(nil)
        } else {
            if feePercent > Decimal(Settings.shared.lightningPaymentFeeLimit.value.rawValue) {
                self.sendStatus.receive(event: .failed(.feePercentageGreaterThanUserLimit(FeeInfo(feePercentage: feePercent, userFeeLimitPercentage: Settings.shared.lightningPaymentFeeLimit.value.rawValue, sendFeeLimitPercentage: 100))))
            } else {
                self.sendStatus.receive(Settings.shared.lightningPaymentFeeLimit.value.rawValue)
            }
        }
    }

    private func setupPrimaryCurrencyListener() {
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
    
    private func updateSubtitle() {
        if isTransactionDust && amount ?? 0 > 0 {
            self.subtitleText.value = L10n.Scene.Send.sendAmountTooSmall
        } else {
            guard let amount = Settings.shared.primaryCurrency.value.format(satoshis: maxPaymentAmount) else {
                return
            }
            
            switch method {
            case .lightning:
                self.subtitleText.value = L10n.Scene.Send.Subtitle.lightningCanSendBalance(amount)
            case .onChain:
                self.subtitleText.value = L10n.Scene.Send.Subtitle.onChainBalance(amount)
            }
        }
    }

    private func updateIsUIEnabled() {
        isSendButtonEnabled.value = isAmountValid && !isSending && !isTransactionDust
        isInputViewEnabled.value = !isSending
        isSubtitleTextWarning.value = amount ?? 0 > maxPaymentAmount || (isTransactionDust && amount ?? 0 > 0)
    }

    private var isAmountValid: Bool {
        guard let amount = amount else { return false }
        return amount > 0 && amount < maxPaymentAmount
    }

    private func updateFee() {
        if isAmountValid {
            fee.value = .loading
            feePercent = nil
            debounceFetchFee()
        } else {
            fee.value = .element(.failure(.invalidAmount))
            feePercent = nil
        }
    }

    private func fetchFee() {
        guard let amount = amount else { return }

        let feeCompletion = { [weak self] (result: Result<(amount: Satoshi, fee: Satoshi?), LndApiError>) -> Void in
            guard
                let self = self
                else { return }
            switch result {
            case .success(let result):
                guard
                    result.amount == self.amount
                    else { return }
                
                self.isTransactionDust = false
                if let fee = result.fee {
                    self.fee.value = .element(.success(fee))
                    self.calculateFeePercent(fee: fee, amount: result.amount)
                } else {
                    self.fee.value = .element(.failure(.invalidAmount))
                    self.feePercent = nil
                }
            case .failure(let lndApiError):
                self.isTransactionDust = lndApiError == .transactionOutputIsDust
                self.fee.value = amount > 0 ? .element(Result.failure(.lndApiError(lndApiError))) : .element(.failure(.invalidAmount))
                self.feePercent = nil
                self.updateIsUIEnabled()
            }
        }

        switch method {
        case .lightning(let paymentRequest):
            lightningService.transactionService.lightningFees(for: paymentRequest, amount: amount, completion: feeCompletion)
        case .onChain(let bitcoinURI):
            lightningService.transactionService.onChainFees(address: bitcoinURI.bitcoinAddress, amount: amount, confirmationTarget: confirmationTarget, completion: feeCompletion)
        }
    }
    
    private func calculateFeePercent(fee: Satoshi, amount: Satoshi) {
        feePercent = ( fee / amount ) * 100
    }
}
