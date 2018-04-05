//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import UIKit

class SendViewController: UIViewController, ContainerViewController {
    
    weak var currentViewController: UIViewController?
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    
    @IBOutlet private weak var paymentTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pasteButtonContainer: UIView!
    @IBOutlet private weak var pasteButton: UIButton!
    @IBOutlet private weak var scannerView: QRCodeScannerView! {
        didSet {
            scannerView.addressTypes = [.lightningInvoice]
            scannerView.handler = { [weak self] type, address in
                self?.displayViewControllerForAddress(type: type, address: address)
            }
        }
    }

    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.deposit.send".localized
        
        Style.button.apply(to: pasteButton)
        pasteButton.setTitleColor(.white, for: .normal)
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func displayViewControllerForAddress(type: AddressType, address: String) {
        guard let viewModel = viewModel else { return }
        
        switch type {
        case .lightningInvoice:
            let viewController = Storyboard.send.instantiate(viewController: SendLightningInvoiceViewController.self)
            viewController.sendViewModel = SendLightningInvoiceViewModel(viewModel: viewModel, lightningInvoice: address)
            setInitialViewController(viewController)
        case .bitcoinAddress:
            let viewController = Storyboard.withdraw.instantiate(viewController: WithdrawViewController.self)
            viewController.withdrawViewModel = WithdrawViewModel(viewModel: viewModel, address: address)
            setInitialViewController(viewController)
        default:
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.pasteButtonContainer.isHidden = true
            self.paymentTopConstraint.isActive = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func pasteButtonTapped(_ sender: Any) {
        guard let string = UIPasteboard.general.string else { return }
        
        for addressType in [AddressType.bitcoinAddress, AddressType.lightningInvoice] where addressType.isValidAddress(string, network: Settings.network) {
            displayViewControllerForAddress(type: addressType, address: string)
            break
        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
