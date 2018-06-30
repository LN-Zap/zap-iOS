//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

protocol QRCodeScannerStrategy {
    var title: String { get }
    var addressTypes: [AddressType] { get }
    
    func viewControllerForAddressType(_ type: AddressType, address: String, lightningService: LightningService) -> UIViewController?
}
