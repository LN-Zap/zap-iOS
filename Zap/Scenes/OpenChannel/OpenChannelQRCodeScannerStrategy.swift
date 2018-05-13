//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

struct OpenChannelQRCodeScannerStrategy: QRCodeScannerStrategy {
    let title = "scene.open_channel.title".localized
    let addressTypes: [AddressType] = [.lightningNode]
    
    func viewControllerForAddressType(_ type: AddressType, address: String, viewModel: ViewModel) -> UIViewController? {
        let viewController = Storyboard.openChannel.initial(viewController: OpenChannelViewController.self)
        viewController.openChannelViewModel = OpenChannelViewModel(viewModel: viewModel, address: address)
        return viewController
    }
}
