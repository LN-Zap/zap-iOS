//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

public protocol QRCodeDetailViewModel {
    var title: String { get }
    var paymentURI: PaymentURI { get }
}

public final class OnChainRequestQRCodeViewModel: QRCodeDetailViewModel {
    public let title = "scene.qr_code_detail.title".localized
    public let paymentURI: PaymentURI

    init(paymentURI: PaymentURI) {
        self.paymentURI = paymentURI
    }
}

public final class LightningRequestQRCodeViewModel: QRCodeDetailViewModel {
    public let title = "scene.qr_code_detail.title".localized
    public let paymentURI: PaymentURI

    init(paymentURI: PaymentURI) {
        self.paymentURI = paymentURI
    }
}
