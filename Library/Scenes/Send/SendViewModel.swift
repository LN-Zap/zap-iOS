//
//  Library
//
//  Created by Otto Suess on 06.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

enum PaymentURIError: Error, Localizable {
    case unknownFormat
    case wrongNetworkError(Network)
    
    var localized: String {
        switch self {
        case .unknownFormat:
            return "error.wrong_uri_format".localized
        case .wrongNetworkError(let network):
            return String(format: "error.wrong_uri_network".localized, network.localized)
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
        } else if let lightningURI = LightningURI(string: uri) {
            paymentURI = lightningURI
        } else {
            return Result(error: PaymentURIError.unknownFormat)
        }
        
        let currentNetwork = lightningService.infoService.network.value
        if paymentURI.network != currentNetwork {
            return Result(error: PaymentURIError.wrongNetworkError(paymentURI.network))
        } else {
            return Result(value: paymentURI)
        }
    }
}
