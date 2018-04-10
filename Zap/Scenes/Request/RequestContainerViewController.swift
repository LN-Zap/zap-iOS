//
//  Zap
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class RequestContainerViewController: UIViewController, ContainerViewController {
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?

    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            self.lightningRequestViewModel = LightningRequestViewModel(viewModel: viewModel)
            self.onChainRequestQRCodeViewModel = OnChainRequestQRCodeViewModel(viewModel: viewModel)
        }
    }
    private var lightningRequestViewModel: LightningRequestViewModel?
    private var onChainRequestQRCodeViewModel: OnChainRequestQRCodeViewModel?
    
    private var lightningRequestViewController: LightningRequestViewController {
        let viewController = Storyboard.request.instantiate(viewController: LightningRequestViewController.self)
        viewController.lightningRequestViewModel = lightningRequestViewModel
        return viewController
    }
    
    private var requestBlockchainViewController: UIViewController {
        let viewController = Storyboard.qrCodeDetail.instantiate(viewController: QRCodeDetailViewController.self)
        viewController.viewModel = onChainRequestQRCodeViewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payment Request"
        
        setInitialViewController(lightningRequestViewController)
    }
    
    @IBAction private func segmentedControlDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToViewController(lightningRequestViewController)
        } else {
            switchToViewController(requestBlockchainViewController)
        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
