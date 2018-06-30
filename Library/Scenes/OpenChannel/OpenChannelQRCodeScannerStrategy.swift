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
    let addressTypes: [AddressType] = [.lightningNode]
    
    func viewControllerForAddressType(_ type: AddressType, address: String, lightningService: LightningService) -> UIViewController? {
        guard let openChannelViewModel = OpenChannelViewModel(lightningService: lightningService, address: address) else { return nil }
        return UIStoryboard.instantiateOpenChannelViewController(with: openChannelViewModel)
    }
}
