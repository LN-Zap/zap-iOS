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
        BitcoinInvoiceFactory.create(from: address, lightningService: lightningService) { [weak self] result in
            guard let self = self else { return }
            completion(result.map {
                let viewModel = SendViewModel(
                    invoice: $0,
                    lightningService: self.lightningService
                )
                return SendViewController(viewModel: viewModel, authenticationViewModel: self.authenticationViewModel)
            })
        }
    }
}
