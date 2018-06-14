//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

public protocol QRCodeDetailViewModel {
    var title: String { get }
    var address: String { get }
}

public final class OnChainRequestQRCodeViewModel: QRCodeDetailViewModel {
    public let title = "scene.deposit.title".localized
    public let address: String

    init(address: String) {
        self.address = address
    }
}

public final class LightningRequestQRCodeViewModel: QRCodeDetailViewModel {
    public let title = "scene.request.title".localized
    public let address: String

    init(invoice: String) {
        self.address = invoice
    }
}
