//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

protocol QRCodeScannerStrategy {
    var title: String { get }
    
    func viewControllerForAddress(address: String, completion: @escaping (Result<UIViewController, InvoiceError>) -> Void)
}
