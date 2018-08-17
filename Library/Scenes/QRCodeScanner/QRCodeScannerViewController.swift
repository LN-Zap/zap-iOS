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
}

protocol QRCodeScannerChildDelegate: class {
    func dismissSuccessfully()
    func presentError(message: String)
}

final class QRCodeScannerViewController: UIViewController {
    @IBOutlet private weak var qrCodeSuccessImageView: UIImageView!
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
                
        Style.button().apply(to: pasteButton)
        
        Style.button(backgroundColor: UIColor.Zap.deepSeaBlue).apply(to: pasteButton)
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        scannerViewOverlay.alpha = 0
        qrCodeSuccessImageView.tintColor = UIColor.Zap.superGreen
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
        guard let qrCodeScannerChildViewController = viewController as? QRCodeScannerChildViewController else { fatalError("presented view is not of type QRCodeScannerChildViewController") }
        qrCodeScannerChildViewController.delegate = self
        present(viewController, animated: true, completion: nil)
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
                self?.qrCodeSuccessImageView.tintColor = .white
                }, completion: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
            })
        }
    }
}
