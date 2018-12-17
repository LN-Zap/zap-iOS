//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Lightning
import SwiftBTC
import UIKit

extension UIStoryboard {
    static func instantiateQRCodeScannerViewController(strategy: QRCodeScannerStrategy) -> UINavigationController {
        let navigationController = StoryboardScene.QRCodeScanner.initialScene.instantiate()
        if let viewController = navigationController.topViewController as? QRCodeScannerViewController {
            viewController.strategy = strategy
        }
        return navigationController
    }
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
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                case .failure(let error):
                    self?.presentError(message: error.localizedDescription)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        guard let modalDetailViewController = viewController as? ModalDetailViewController else { fatalError("presented view is not of type ModalDetailViewController") }
        modalDetailViewController.delegate = self
        present(modalDetailViewController, animated: true, completion: nil)
    }
    
    @IBAction private func pasteButtonTapped(_ sender: Any) {
        if let string = UIPasteboard.general.string {
            tryPresentingViewController(for: string)
        } else {
            presentError(message: L10n.Generic.Pasteboard.invalidAddress)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension QRCodeScannerViewController: ModalDetailViewControllerDelegate {
    func childWillDisappear() {
        scannerView.start()
    }
    
    func presentError(message: String) {
        Toast.presentError(message)
    }
}
