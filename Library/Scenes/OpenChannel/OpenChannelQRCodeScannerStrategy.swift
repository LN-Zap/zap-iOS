//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

struct OpenChannelQRCodeScannerStrategy: QRCodeScannerStrategy {
    let title = "scene.open_channel.title".localized
    
    func viewControllerForAddress(address: String, lightningService: LightningService, callback: (Result<UIViewController>) -> Void) {
        if let nodeURI = LightningNodeURI(string: address) {
            let openChannelViewModel = OpenChannelViewModel(lightningService: lightningService, lightningNodeURI: nodeURI)
            callback(.success(UIStoryboard.instantiateOpenChannelViewController(with: openChannelViewModel)))
        } else {
            callback(.failure(InvoiceError.unknownFormat))
        }
    }
}
