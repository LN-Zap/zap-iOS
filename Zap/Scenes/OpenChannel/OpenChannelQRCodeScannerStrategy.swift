//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

struct OpenChannelQRCodeScannerStrategy: QRCodeScannerStrategy {
    var title = "Open Channel"
    
    var addressTypes: [AddressType] = [.lightningNode]
    
    func viewControllerForAddressType(_ type: AddressType, address: String, viewModel: ViewModel) -> UIViewController? {
        return UIViewController()
    }
}
