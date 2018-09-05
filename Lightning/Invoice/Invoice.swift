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
    case wrongNetworkError(linkNetwork: Network, expectedNetwork: Network)
}

public final class Invoice {
    public let lightningPaymentRequest: PaymentRequest?
    public let bitcoinURI: BitcoinURI?

    private init(lightningPaymentRequest: PaymentRequest?, bitcoinURI: BitcoinURI?) {
        self.lightningPaymentRequest = lightningPaymentRequest
        self.bitcoinURI = bitcoinURI
    }
    
    public static func create(from address: String, lightningService: LightningService, completion: @escaping (Result<Invoice>) -> Void) {

        if let bitcoinURI = BitcoinURI(string: address) {
            if let paymentRequest = bitcoinURI.lightningFallback,
                let invoiceURI = LightningInvoiceURI(string: paymentRequest) {
                decodeLightningPaymentRequest(invoiceURI: invoiceURI, bitcoinURI: bitcoinURI, lightningService: lightningService, completion: completion)
            } else {
                validateInvoice(Invoice(lightningPaymentRequest: nil, bitcoinURI: bitcoinURI), lightningService: lightningService, completion: completion)
            }
        } else if let invoiceURI = LightningInvoiceURI(string: address) {
            decodeLightningPaymentRequest(invoiceURI: invoiceURI, bitcoinURI: nil, lightningService: lightningService, completion: completion)
        } else {
            completion(.failure(InvoiceError.unknownFormat))
        }
    }
    
    private static func decodeLightningPaymentRequest(invoiceURI: LightningInvoiceURI, bitcoinURI: BitcoinURI?, lightningService: LightningService, completion: @escaping (Result<Invoice>) -> Void) {
        lightningService.transactionService.decodePaymentRequest(invoiceURI.address) { result in
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
                
                validateInvoice(invoice, lightningService: lightningService, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func validateInvoice(_ invoice: Invoice, lightningService: LightningService, completion: (Result<Invoice>) -> Void) {
        let currentNetwork = lightningService.infoService.network.value
        
        if let bitcoinURI = invoice.bitcoinURI,
            bitcoinURI.network != currentNetwork {
            completion(.failure(InvoiceError.wrongNetworkError(linkNetwork: bitcoinURI.network, expectedNetwork: currentNetwork)))
        } else if let lightningPaymentRequest = invoice.lightningPaymentRequest,
            lightningPaymentRequest.network != currentNetwork {
            completion(.failure(InvoiceError.wrongNetworkError(linkNetwork: lightningPaymentRequest.network, expectedNetwork: currentNetwork)))
        } else {
            completion(.success(invoice))
        }
    }
}
