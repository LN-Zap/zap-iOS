//
//  Library
//
//  Created by Otto Suess on 06.07.18.
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
    let lightningService: LightningService
    
    init(lightningService: LightningService) {
        self.lightningService = lightningService
    }
    
    func paymentURI(for uri: String) -> Result<PaymentURI> {
        let paymentURI: PaymentURI
        
        if let bitcoinURI = BitcoinURI(string: uri) {
            paymentURI = bitcoinURI
        } else if let lightningURI = LightningInvoiceURI(string: uri) {
            paymentURI = lightningURI
        } else {
            return Result(error: InvoiceError.unknownFormat)
        }
        
        let currentNetwork = lightningService.infoService.network.value
        if paymentURI.network != currentNetwork {
            return Result(error: InvoiceError.wrongNetworkError(linkNetwork: paymentURI.network, nodeNetwork: currentNetwork))
        } else {
            return Result(value: paymentURI)
        }
    }
}
