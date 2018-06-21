//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateConnectRemoteNodeViewController(didSetupWallet: @escaping () -> Void, connectRemoteNodeViewModel: ConnectRemoteNodeViewModel, presentQRCodeScannerButtonTapped: @escaping (() -> Void)) -> ConnectRemoteNodeViewController {
        let viewController = Storyboard.connectRemoteNode.initial(viewController: ConnectRemoteNodeViewController.self)
        viewController.didSetupWallet = didSetupWallet
        viewController.connectRemoteNodeViewModel = connectRemoteNodeViewModel
        viewController.presentQRCodeScannerButtonTapped = presentQRCodeScannerButtonTapped
        return viewController
    }
}

final class ConnectRemoteNodeViewController: UIViewController {
    
    @IBOutlet private weak var urlLabel: UILabel!
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var scanCertificatesButton: UIButton!
    @IBOutlet private weak var pasteCertificatesButton: UIButton!
    @IBOutlet private weak var lineView: LineView! {
        didSet {
            lineView.color = UIColor.zap.warmGrey
        }
    }
    
    @IBOutlet private weak var connectButton: GradientLoadingButtonView!
    @IBOutlet private weak var textView: UITextView!
    
    fileprivate var presentQRCodeScannerButtonTapped: (() -> Void)?
    fileprivate var didSetupWallet: (() -> Void)?
    
    var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Connect Remote Node"
        
        Style.label.apply(to: urlLabel) {
            $0.textColor = .white
        }
        Style.textField.apply(to: urlTextField) {
            $0.textColor = .white
        }
        Style.button.apply(to: scanCertificatesButton, pasteCertificatesButton) {
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            $0.tintColor = .white
        }
        
        urlTextField.attributedPlaceholder =
            NSAttributedString(string: "192.168.1.3:10009", attributes: [.foregroundColor: UIColor.lightGray])
        urlTextField.delegate = self
        
        UIView.performWithoutAnimation {
            scanCertificatesButton.setTitle("scan", for: .normal)
            scanCertificatesButton.layoutIfNeeded()
            pasteCertificatesButton.setTitle("paste", for: .normal)
            pasteCertificatesButton.layoutIfNeeded()
        }
        
        connectButton.title = "Connect"
        
        textView.font = UIFont(name: "Courier", size: 12)
        textView.backgroundColor = .clear
        textView.textColor = .lightGray
        
        connectRemoteNodeViewModel?.certificatesString
            .bind(to: textView.reactive.text)
            .dispose(in: reactive.bag)
        
        connectRemoteNodeViewModel?.urlString
            .bidirectionalBind(to: urlTextField.reactive.text)
            .dispose(in: reactive.bag)
        
        connectRemoteNodeViewModel?.isInputValid
            .bind(to: connectButton.reactive.isEnabled)
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func presentQRCodeScanner(_ sender: Any) {
        presentQRCodeScannerButtonTapped?()
    }
    
    @IBAction private func pasteCertificates(_ sender: Any) {
        connectRemoteNodeViewModel?.pasteCertificates()
    }
    
    @IBAction private func connectRemoteNode(_ sender: Any) {
        connectRemoteNodeViewModel?.connect { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.didSetupWallet?()
                } else {
                    self?.displayError()
                }
            }
        }
    }
    
    private func displayError() {
        DispatchQueue.main.async { [weak self] in
            self?.displayError("Could not connect to server.")
            self?.connectButton.isLoading = false
        }
    }
}

extension ConnectRemoteNodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
