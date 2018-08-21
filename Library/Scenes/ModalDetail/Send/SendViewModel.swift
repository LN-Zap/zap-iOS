//
//  Library
//
//  Created by Otto Suess on 18.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

extension InvoiceError: Localizable {
    public var localized: String {
        switch self {
        case .unknownFormat:
            return "error.wrong_uri_format".localized
        case let .wrongNetworkError(linkNetwork, nodeNetwork):
            return String(format: "error.wrong_uri_network".localized, linkNetwork.localized, nodeNetwork.localized)
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
                return "Send Lightning Payment"
            case .onChain:
                return "Send On Chain"
            }
        }
    }
    
    private let invoice: Invoice
    let method: SendMethod
    
    var amount: Satoshi?
    let receiver: String
    let memo: String?
    
    let validRange: ClosedRange<Satoshi>?

    private let transactionAnnotationStore: TransactionAnnotationStore
    private let nodeStore: LightningNodeStore
    private let lightningService: LightningService
    
    init(invoice: Invoice, transactionAnnotationStore: TransactionAnnotationStore, nodeStore: LightningNodeStore, lightningService: LightningService) {
        self.invoice = invoice
        self.transactionAnnotationStore = transactionAnnotationStore
        self.nodeStore = nodeStore
        self.lightningService = lightningService
        
        if let paymentRequest = invoice.lightningPaymentRequest {
            method = .lightning(paymentRequest)
        } else if let bitcoinURI = invoice.bitcoinURI {
            method = .onChain(bitcoinURI)
        } else {
            fatalError("Invalid Invoice")
        }
        
        receiver = invoice.lightningPaymentRequest?.destination ?? invoice.bitcoinURI?.address ?? "-"
        amount = invoice.lightningPaymentRequest?.amount ?? invoice.bitcoinURI?.amount
        memo = invoice.lightningPaymentRequest?.memo ?? invoice.bitcoinURI?.memo
        
        if lightningService.balanceService.onChain.value == 0 {
            validRange = nil
        } else {
            validRange = Constants.minimumOnChainTransaction...lightningService.balanceService.onChain.value
        }
    }
    
    func send(callback: @escaping (Result<Success>) -> Void) {
        guard let amount = amount else { return }
        
        switch method {
        case .lightning(let paymentRequest):
            sendLightning(paymentRequest: paymentRequest, amount: amount) { result in
                callback(result.map { _ in Success() })
            }
        case .onChain(let bitcoinURI):
            sendOnChain(bitcoinURI: bitcoinURI, amount: amount) { result in
                callback(result.map { _ in Success() })
            }
        }
    }
    
    private func sendOnChain(bitcoinURI: BitcoinURI, amount: Satoshi, callback: @escaping (Result<OnChainUnconfirmedTransaction>) -> Void) {
        lightningService.transactionService.sendCoins(address: bitcoinURI.address, amount: amount) { [weak self] in
            if let unconfirmedTransaction = $0.value,
                let memo = self?.memo {
                self?.transactionAnnotationStore.udpateMemo(memo, forTransactionId: unconfirmedTransaction.id)
            }
            callback($0)
        }
    }

    private func sendLightning(paymentRequest: PaymentRequest, amount: Satoshi, callback: @escaping (Result<Data>) -> Void) {
        lightningService.transactionService.sendPayment(paymentRequest, amount: amount) { [weak self] in
            self?.transactionAnnotationStore.udpateMemo(paymentRequest.memo, forTransactionId: paymentRequest.paymentHash)
            callback($0)
        }
    }
}
