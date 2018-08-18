//
//  Lightning
//
//  Created by Otto Suess on 18.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public enum InvoiceError: Error {
    case unknownFormat
    case wrongNetworkError(linkNetwork: Network, nodeNetwork: Network)
}

final class Invoice {
    let lightningPaymentRequest: PaymentRequest?
    let bitcoinURI: BitcoinURI?

    private init(lightningPaymentRequest: PaymentRequest?, bitcoinURI: BitcoinURI?) {
        self.lightningPaymentRequest = lightningPaymentRequest
        self.bitcoinURI = bitcoinURI
    }
    
    static func create(from address: String, lightningService: LightningService, callback: @escaping (Result<Invoice>) -> Void) {

        if let bitcoinURI = BitcoinURI(string: address) {
            if let lightningPaymentRequest = bitcoinURI.lightningFallback {
                decodeLightningPaymentRequest(paymentRequest: lightningPaymentRequest, bitcoinURI: bitcoinURI, lightningService: lightningService, callback: callback)
            } else {
                validateInvoice(Invoice(lightningPaymentRequest: nil, bitcoinURI: bitcoinURI), lightningService: lightningService, callback: callback)
            }
        } else if LightningInvoiceURI(string: address) != nil {
            decodeLightningPaymentRequest(paymentRequest: address, bitcoinURI: nil, lightningService: lightningService, callback: callback)
        } else {
            callback(.failure(InvoiceError.unknownFormat))
        }
    }
    
    private static func decodeLightningPaymentRequest(paymentRequest: String, bitcoinURI: BitcoinURI?, lightningService: LightningService, callback: @escaping (Result<Invoice>) -> Void) {
        lightningService.transactionService.decodePaymentRequest(paymentRequest) { result in
            switch result {
            case .success(let paymentRequest):
                let invoice: Invoice
                
                if bitcoinURI == nil,
                    let fallbackAddress = paymentRequest.fallbackAddress,
                    let fallbackBitcoinURI = BitcoinURI(string: fallbackAddress) {
                    invoice = Invoice(lightningPaymentRequest: paymentRequest, bitcoinURI: fallbackBitcoinURI)
                } else {
                    invoice = Invoice(lightningPaymentRequest: paymentRequest, bitcoinURI: bitcoinURI)
                }
                
                validateInvoice(invoice, lightningService: lightningService, callback: callback)
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    private static func validateInvoice(_ invoice: Invoice, lightningService: LightningService, callback: (Result<Invoice>) -> Void) {
        let currentNetwork = lightningService.infoService.network.value
        
        if let bitcoinURI = invoice.bitcoinURI,
            bitcoinURI.network != currentNetwork {
            callback(.failure(InvoiceError.wrongNetworkError(linkNetwork: bitcoinURI.network, nodeNetwork: currentNetwork)))
        } else if let lightningPaymentRequest = invoice.lightningPaymentRequest,
            lightningPaymentRequest.network != currentNetwork {
            callback(.failure(InvoiceError.wrongNetworkError(linkNetwork: lightningPaymentRequest.network, nodeNetwork: currentNetwork)))
        } else {
            callback(.success(invoice))
        }
    }
}
