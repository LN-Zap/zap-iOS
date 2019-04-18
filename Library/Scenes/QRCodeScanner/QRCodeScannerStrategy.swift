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

enum QRCodeScannerStrategyError: Error {
    case unknownFormat
}

protocol QRCodeScannerStrategy {
    var title: String { get }
    var pasteButtonTitle: String { get }

    func viewControllerForAddress(address: String, completion: @escaping (Result<UIViewController, QRCodeScannerStrategyError>) -> Void)
}
