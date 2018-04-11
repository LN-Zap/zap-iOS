//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

protocol QRCodeDetailViewModel {
    var title: String { get }
    var address: String { get }
}

final class OnChainRequestQRCodeViewModel: QRCodeDetailViewModel {
    let title = "scene.deposit.title".localized
    let address: String

    init(address: String) {
        self.address = address
    }
}

final class LightningRequestQRCodeViewModel: QRCodeDetailViewModel {
    let title = "scene.request.title".localized
    let address: String

    init(invoice: String) {
        self.address = invoice
    }
}
