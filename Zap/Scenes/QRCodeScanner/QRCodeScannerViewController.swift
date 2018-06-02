//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import UIKit

protocol QRCodeScannerChildViewController: class {
    var delegate: QRCodeScannerChildDelegate? { get set }
    var contentHeight: CGFloat { get }
}

protocol QRCodeScannerChildDelegate: class {
    func dismissSuccessfully()
}

class QRCodeScannerViewController: UIViewController, ContainerViewController {
    
    weak var currentViewController: UIViewController?
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    
    @IBOutlet private weak var successView: UIView!
    @IBOutlet private weak var qrCodeOverlayImageView: UIImageView!
    @IBOutlet private weak var qrCodeSuccessImageView: UIImageView!
    
    @IBOutlet private weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var paymentTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pasteButtonContainer: UIView!
    @IBOutlet private weak var pasteButton: UIButton!
    @IBOutlet private weak var scannerView: QRCodeScannerView! {
        didSet {
            scannerView.addressTypes = strategy?.addressTypes
            scannerView.viewModel = viewModel
            scannerView.handler = { [weak self] type, address in
                self?.displayViewControllerForAddress(type: type, address: address)
            }
        }
    }
    @IBOutlet private weak var scannerViewOverlay: UIView!

    var strategy: QRCodeScannerStrategy? {
        didSet {
            scannerView?.addressTypes = strategy?.addressTypes
            title = strategy?.title
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var viewModel: ViewModel? {
        didSet {
            scannerView?.viewModel = viewModel
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.button.apply(to: pasteButton)
        pasteButton.setTitleColor(.white, for: .normal)
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        scannerViewOverlay.alpha = 0
        successView.backgroundColor = UIColor.zap.green
        qrCodeSuccessImageView.tintColor = UIColor.zap.green
    }
    
    func displayViewControllerForAddress(type: AddressType, address: String) {
        guard
            let viewModel = viewModel,
            let viewController = strategy?.viewControllerForAddressType(type, address: address, viewModel: viewModel)
            else { return }
        
        setContainerContent(viewController)
        
        if let viewController = viewController as? QRCodeScannerChildViewController {
            containerViewHeightConstraint?.constant = viewController.contentHeight
            viewController.delegate = self
        } else {
            fatalError("no vc height provided")
        }
        
        UIView.animate(withDuration: 0.25) {
            self.qrCodeOverlayImageView.alpha = 0
            self.qrCodeSuccessImageView.alpha = 1
            self.scannerViewOverlay.alpha = 0.8
            self.pasteButtonContainer.isHidden = true
            self.paymentTopConstraint.isActive = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func pasteButtonTapped(_ sender: Any) {
        guard
            let string = UIPasteboard.general.string,
            let strategy = strategy,
            let network = viewModel?.info.network.value
            else { return }
        
        for addressType in strategy.addressTypes where addressType.isValidAddress(string, network: network) {
            displayViewControllerForAddress(type: addressType, address: string)
            break
        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension QRCodeScannerViewController: QRCodeScannerChildDelegate {
    func dismissSuccessfully() {
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.successView.alpha = 1
                self?.qrCodeSuccessImageView.tintColor = .white
                }, completion: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
            })
        }
    }
}
