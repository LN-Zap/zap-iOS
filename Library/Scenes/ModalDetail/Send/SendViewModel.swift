//
//  Library
//
//  Created by Otto Suess on 18.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

extension InvoiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownFormat:
            return "error.wrong_uri_format".localized
        case let .wrongNetworkError(linkNetwork, expectedNetwork):
            return String(format: "error.wrong_uri_network".localized, linkNetwork.localized, expectedNetwork.localized)
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
                return "scene.send.lightning.title".localized
            case .onChain:
                return "scene.send.on_chain.title".localized
            }
        }
    }
    
    private let invoice: BitcoinInvoice
    let method: SendMethod
    
    var amount: Satoshi?
    let receiver: String
    let memo: String?
    
    let validRange: ClosedRange<Satoshi>?

    private let lightningService: LightningService
    
    init(invoice: BitcoinInvoice, lightningService: LightningService) {
        self.invoice = invoice
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
        
        if lightningService.balanceService.onChain.value == 0 {
            validRange = nil
        } else {
            validRange = Constants.minimumOnChainTransaction...lightningService.balanceService.onChain.value
        }
    }
    
    func send(completion: @escaping (Result<Success>) -> Void) {
        guard let amount = amount else { return }
        lightningService.transactionService.send(invoice, amount: amount, completion: completion)
    }
}
