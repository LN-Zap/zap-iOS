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
            let name: String
            switch self {
            case .lightning:
                name = "icon_header_lightning"
            case .onChain:
                name = "icon_header_on_chain"
            }
            guard let image = UIImage(named: name, in: Bundle.library, compatibleWith: nil) else { fatalError("Image not found") }
            return image
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
            needsFeeUpdate = true
            updateLightningFee()
            updateSendButtonEnabled()
        }
    }
    var isSending = false {
        didSet {
            updateSendButtonEnabled()
        }
    }
    
    let receiver: String
    let memo: String?
    let sendButtonEnabled = Observable(false)
    let validRange: ClosedRange<Satoshi>?
    var needsFeeUpdate = true
    
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
    }
    
    private func updateSendButtonEnabled() {
        sendButtonEnabled.value = isSendButtonEnabled
    }
    
    private var isAmountValid: Bool {
        guard
            let amount = amount,
            let validRange = validRange
            else { return false }
        return validRange.contains(amount)
    }
    
    private var isSendButtonEnabled: Bool {
        guard isAmountValid && !isSending else { return false }
        
        switch method {
        case .onChain:
            return true
        case .lightning:
            return !needsFeeUpdate
        }
    }
    
    private func updateLightningFee() {
        guard case .lightning = method else { return }
        
        if isAmountValid {
            needsFeeUpdate = true
            lightningFee.value = .loading
            updateSendButtonEnabled()
            debounceFetchFee()
        } else {
            lightningFee.value = .element(nil)
            needsFeeUpdate = false
        }
    }
    
    private func fetchLightningFee() {
        guard
            case .lightning(let paymentRequest) = method,
            let amount = amount
            else { return }

        lightningService.transactionService.upperBoundLightningFees(for: paymentRequest, amount: amount) { [weak self] in
            guard $0.value?.amount == self?.amount else { return }
            
            self?.needsFeeUpdate = false
            self?.lightningFee.value = .element($0.value?.fee)
            self?.updateSendButtonEnabled()
        }
    }
    
    func send(completion: @escaping (Result<Success>) -> Void) {
        guard let amount = amount else { return }
        
        isSending = true
        
        switch method {
        case .lightning(let paymentRequest):
            guard
                case .element(let optionalFee) = lightningFee.value,
                let fee = optionalFee
                else { return }
            
            let maxFee = min(fee * 2, 100)
            
            lightningService.transactionService.sendPayment(paymentRequest, amount: amount, maxFee: maxFee, completion: completion)
        case .onChain(let bitcoinURI):
            lightningService.transactionService.sendCoins(bitcoinURI: bitcoinURI, amount: amount, completion: completion)
        }
    }
}
