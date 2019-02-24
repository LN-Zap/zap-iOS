//
//  Lightning
//
//  Created by Otto Suess on 18.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftBTC
import SwiftLnd

public enum InvoiceError: Error {
    case unknownFormat
    case wrongNetworkError(linkNetwork: Network, expectedNetwork: Network)
    case apiError(String)
}

/*
 Can be either a payment request or a bitcoinURI or both. (bitcoin uri with
 ln fallback or ln invoice with on-chain fallback.
 */
public final class BitcoinInvoice {
    public let lightningPaymentRequest: PaymentRequest?
    public let bitcoinURI: BitcoinURI?

    init(lightningPaymentRequest: PaymentRequest?, bitcoinURI: BitcoinURI?) {
        self.lightningPaymentRequest = lightningPaymentRequest
        self.bitcoinURI = bitcoinURI
    }
}

public enum BitcoinInvoiceFactory {
    public static func create(from address: String, lightningService: LightningService, completion: @escaping (Result<BitcoinInvoice, InvoiceError>) -> Void) {
        if let bitcoinURI = BitcoinURI(string: address) {
            if let paymentRequest = bitcoinURI.lightningFallback,
                let invoiceURI = LightningInvoiceURI(string: paymentRequest) {
                decodeLightningPaymentRequest(invoiceURI: invoiceURI, bitcoinURI: bitcoinURI, lightningService: lightningService, completion: completion)
            } else {
                validateInvoice(BitcoinInvoice(lightningPaymentRequest: nil, bitcoinURI: bitcoinURI), lightningService: lightningService, completion: completion)
            }
        } else if let invoiceURI = LightningInvoiceURI(string: address) {
            decodeLightningPaymentRequest(invoiceURI: invoiceURI, bitcoinURI: nil, lightningService: lightningService, completion: completion)
        } else {
            completion(.failure(InvoiceError.unknownFormat))
        }
    }

    private static func decodeLightningPaymentRequest(invoiceURI: LightningInvoiceURI, bitcoinURI: BitcoinURI?, lightningService: LightningService, completion: @escaping (Result<BitcoinInvoice, InvoiceError>) -> Void) {
        lightningService.transactionService.decodePaymentRequest(invoiceURI.address) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let paymentRequest):
                    let invoice: BitcoinInvoice

                    if bitcoinURI == nil,
                        let fallbackAddress = paymentRequest.fallbackAddress,
                        let fallbackBitcoinURI = BitcoinURI(address: fallbackAddress, amount: nil, memo: nil, lightningFallback: nil) {
                        invoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: fallbackBitcoinURI)
                    } else {
                        invoice = BitcoinInvoice(lightningPaymentRequest: paymentRequest, bitcoinURI: bitcoinURI)
                    }

                    validateInvoice(invoice, lightningService: lightningService, completion: completion)
                case .failure(let error):
                    completion(.failure(.apiError(error.localizedDescription)))
                }
            }
        }
    }

    private static func validateInvoice(_ invoice: BitcoinInvoice, lightningService: LightningService, completion: (Result<BitcoinInvoice, InvoiceError>) -> Void) {
        guard let currentNetwork = lightningService.infoService.network.value else { return }

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
