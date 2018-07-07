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
    
    func viewControllerForAddress(address: String, lightningService: LightningService) -> Result<UIViewController>? {
        guard let nodeURI = LightningNodeURI(string: address) else { return nil }
            
        let openChannelViewModel = OpenChannelViewModel(lightningService: lightningService, lightningNodeURI: nodeURI)
        return Result(value: UIStoryboard.instantiateOpenChannelViewController(with: openChannelViewModel))
    }
}
