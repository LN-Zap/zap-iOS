//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateQRCodeScannerViewController(with lightningService: LightningService, strategy: QRCodeScannerStrategy) -> UINavigationController {
        let navigationController = Storyboard.qrCodeScanner.initial(viewController: UINavigationController.self)
        if let viewController = navigationController.topViewController as? QRCodeScannerViewController {
            viewController.lightningService = lightningService
            viewController.strategy = strategy
        }
        return navigationController
    }
}

protocol QRCodeScannerChildViewController: class {
    var delegate: QRCodeScannerChildDelegate? { get set }
    var contentHeight: CGFloat { get }
}

protocol QRCodeScannerChildDelegate: class {
    func dismissSuccessfully()
    func presentError(message: String)
}

final class QRCodeScannerViewController: UIViewController, ContainerViewController {
    
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
            scannerView.lightningService = lightningService
            scannerView.handler = { [weak self] address in
                self?.tryPresentingViewController(for: address)
            }
        }
    }
    @IBOutlet private weak var scannerViewOverlay: UIView!

    fileprivate var strategy: QRCodeScannerStrategy? {
        didSet {
            title = strategy?.title
        }
    }
    
    fileprivate var lightningService: LightningService? {
        didSet {
            scannerView?.lightningService = lightningService
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        Style.button.apply(to: pasteButton)
        pasteButton.setTitleColor(.white, for: .normal)
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        scannerViewOverlay.alpha = 0
        qrCodeSuccessImageView.tintColor = UIColor.zap.nastyGreen
    }
    
    func tryPresentingViewController(for address: String) {
        guard
            let lightningService = lightningService,
            let result = strategy?.viewControllerForAddress(address: address, lightningService: lightningService)
            else { return }
        
        switch result {
        case .success(let viewController):
            presentViewController(viewController)

            scannerView.stop()
        case .failure(let error):
            if let message = (error as? PaymentURIError)?.localized {
                presentError(message: message)
            }
        }
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        setContainerContent(viewController)
        
        applyCornerRoundingMask(to: viewController.view)
        
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
    
    private func applyCornerRoundingMask(to view: UIView) {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
    
    @IBAction private func pasteButtonTapped(_ sender: Any) {
        guard let string = UIPasteboard.general.string else { return }
        _ = tryPresentingViewController(for: string)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension QRCodeScannerViewController: QRCodeScannerChildDelegate {
    func presentError(message: String) {
        navigationController?.presentErrorToast(message)
    }
    
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
