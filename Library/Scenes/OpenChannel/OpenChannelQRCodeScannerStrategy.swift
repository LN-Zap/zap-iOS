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

struct OpenChannelQRCodeScannerStrategy: QRCodeScannerStrategy {
    private let lightningService: LightningService
    
    let title = L10n.Scene.OpenChannel.title
    
    init(lightningService: LightningService) {
        self.lightningService = lightningService
    }
    
    func viewControllerForAddress(address: String, completion: @escaping (Result<UIViewController>) -> Void) {
        if let nodeURI = LightningNodeURI(string: address) {
            let openChannelViewModel = OpenChannelViewModel(lightningService: lightningService, lightningNodeURI: nodeURI)
            completion(.success(OpenChannelViewController(viewModel: openChannelViewModel)))
        } else {
            completion(.failure(InvoiceError.unknownFormat))
        }
    }
}
