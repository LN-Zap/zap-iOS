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
    private let lightningService: LightningService
    
    let title = "scene.open_channel.title".localized
    
    init(lightningService: LightningService) {
        self.lightningService = lightningService
    }
    
    func viewControllerForAddress(address: String, callback: @escaping (Result<UIViewController>) -> Void) {
        if let nodeURI = LightningNodeURI(string: address) {
            let openChannelViewModel = OpenChannelViewModel(lightningService: lightningService, lightningNodeURI: nodeURI)
            callback(.success(UIStoryboard.instantiateOpenChannelViewController(with: openChannelViewModel)))
        } else {
            callback(.failure(InvoiceError.unknownFormat))
        }
    }
}
