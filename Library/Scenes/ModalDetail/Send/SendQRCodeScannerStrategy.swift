//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning
import SwiftLnd

class SendQRCodeScannerStrategy: QRCodeScannerStrategy {
    private let lightningService: LightningService
    private let authenticationViewModel: AuthenticationViewModel
    
    let title = "scene.send.title".localized
    
    init(lightningService: LightningService, authenticationViewModel: AuthenticationViewModel) {
        self.lightningService = lightningService
        self.authenticationViewModel = authenticationViewModel
    }
    
    func viewControllerForAddress(address: String, completion: @escaping (Result<UIViewController>) -> Void) {
        BitcoinInvoice.create(from: address, lightningService: lightningService) { [weak self] result in
            guard let strongSelf = self else { return }
            completion(result.map {
                let viewModel = SendViewModel(
                    invoice: $0,
                    lightningService: strongSelf.lightningService
                )
                return SendViewController(viewModel: viewModel, authenticationViewModel: strongSelf.authenticationViewModel)
            })
        }
    }
}
