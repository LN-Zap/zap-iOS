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
    static func instantiateQRCodeScannerViewController(strategy: QRCodeScannerStrategy) -> UINavigationController {
        let navigationController = Storyboard.qrCodeScanner.initial(viewController: UINavigationController.self)
        if let viewController = navigationController.topViewController as? QRCodeScannerViewController {
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        Style.Button.background.apply(to: pasteButton)
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        scannerViewOverlay.alpha = 0
        qrCodeSuccessImageView.tintColor = UIColor.Zap.superGreen
    }
    
    func tryPresentingViewController(for address: String) {
        strategy?.viewControllerForAddress(address: address) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let viewController):
                    self?.presentViewController(viewController)
                    self?.scannerView.stop()
                case .failure(let error):
                    if let message = (error as? InvoiceError)?.localized {
                        self?.presentError(message: message)
                    }
                }
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
