//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

class SendQRCodeScannerStrategy: QRCodeScannerStrategy {
    private let nodeStore: LightningNodeStore
    private let lightningService: LightningService
    private let authenticationViewModel: AuthenticationViewModel
    
    let title = "scene.send.title".localized
    
    init(nodeStore: LightningNodeStore, lightningService: LightningService, authenticationViewModel: AuthenticationViewModel) {
        self.nodeStore = nodeStore
        self.lightningService = lightningService
        self.authenticationViewModel = authenticationViewModel
    }
    
    func viewControllerForAddress(address: String, completion: @escaping (Result<UIViewController>) -> Void) {
        Invoice.create(from: address, lightningService: lightningService) { [weak self] result in
            guard let strongSelf = self else { return }
            completion(result.map {
                let viewModel = SendViewModel(
                    invoice: $0,
                    nodeStore: strongSelf.nodeStore,
                    lightningService: strongSelf.lightningService
                )
                return SendViewController(viewModel: viewModel, authenticationViewModel: strongSelf.authenticationViewModel)
            })
        }
    }
}
