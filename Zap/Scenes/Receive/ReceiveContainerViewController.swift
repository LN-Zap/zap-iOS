//
//  Zap
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class ReceiveContainerViewController: UIViewController, ContainerViewController {
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?

    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            self.createReceiveViewModel = CreateReceiveViewModel(viewModel: viewModel)
            self.depositViewModel = DepositViewModel(viewModel: viewModel)
        }
    }
    private var createReceiveViewModel: CreateReceiveViewModel?
    private var depositViewModel: DepositViewModel?
    
    private var receiveLightningViewController: ReceiveViewController {
        let viewController = Storyboard.receive.instantiate(viewController: ReceiveViewController.self)
        viewController.createReceiveViewModel = createReceiveViewModel
        return viewController
    }
    
    private var receiveBlockchainViewController: UIViewController {
        let viewController = Storyboard.qrCodeDetail.instantiate(viewController: QRCodeDetailViewController.self)
        viewController.viewModel = depositViewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payment Request"
        
        setInitialViewController(receiveLightningViewController)
    }
    
    @IBAction private func segmentedControlDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToViewController(receiveLightningViewController)
        } else {
            switchToViewController(receiveBlockchainViewController)
        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
