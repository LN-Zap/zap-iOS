//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateConnectRemoteNodeViewController(didSetupWallet: @escaping () -> Void) -> ConnectRemoteNodeViewController {
        let viewController = Storyboard.connectRemoteNode.initial(viewController: ConnectRemoteNodeViewController.self)
        viewController.didSetupWallet = didSetupWallet
        return viewController
    }
}

protocol SetupWalletDelegate: class {
    func didSetupWallet()
}

class ConnectRemoteNodeViewController: UIViewController {
    
    @IBOutlet private weak var urlLabel: UILabel!
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var scanCertificatesButton: UIButton!
    @IBOutlet private weak var pasteCertificatesButton: UIButton!
    @IBOutlet private weak var lightBackgroundView: UIView!
    @IBOutlet private weak var lineView: LineView! {
        didSet {
            lineView.color = UIColor.zap.darkTableViewSeparator
        }
    }
    
    @IBOutlet private weak var connectButton: GradientLoadingButtonView!
    @IBOutlet private weak var textView: UITextView!
    
    private var certificates: RemoteNodeCertificates? {
        didSet {
            updateCertificatesUI()
        }
    }
    
    fileprivate var didSetupWallet: (() -> Void)?
    
    var testServer: LndRpcServer?
    var connectCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Connect Remote Node"
        
        view.backgroundColor = UIColor.zap.darkBackground
        lightBackgroundView.backgroundColor = UIColor.zap.mediumBackground
        
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
        
        let configuration = RemoteNodeConfiguration.load()
        certificates = configuration?.remoteNodeCertificates
        urlTextField.text = configuration?.url.absoluteString ?? "192.168.1.3:10011" // TODO: remove fallback
    }
    
    private func updateCertificatesUI() {
        guard let certificates = certificates else { return }
        let certString: String = certificates.certificate
        let macString: String = certificates.macaron.base64EncodedString()
        
        textView.text = "\(certString)\n\n\(macString)"
    }
    
    @IBAction private func presentQRCodeScanner(_ sender: Any) {
        let viewController = UIStoryboard.instantiateRemoteNodeCertificatesScannerViewController(with: self)
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction private func pasteCertificates(_ sender: Any) {
        guard
            let jsonString = UIPasteboard.general.string,
            let remoteNodeCertificates = RemoteNodeCertificates(json: jsonString)
            else { return }
        self.certificates = remoteNodeCertificates
    }
    
    @IBAction private func connectRemoteNode(_ sender: Any) {
        guard
            let urlString = urlTextField.text,
            let url = URL(string: urlString),
            let certificates = certificates
            else { return }
    
        let remoteNodeConfiguration = RemoteNodeConfiguration(remoteNodeCertificates: certificates, url: url)
        remoteNodeConfiguration.save()

        testServer = LndRpcServer(configuration: remoteNodeConfiguration)
    
        testServer?.canConnect { [weak self] in
            print("🖇 can connect to remote server:", $0)
            
            if $0 {
                self?.connect()
            } else {
                self?.displayError()
            }
        }
    }
    
    private func displayError() {
        DispatchQueue.main.async { [weak self] in
            self?.displayError("Could not connect to server.")
            self?.connectButton.isLoading = false
        }
    }
    
    private func connect() {
        didSetupWallet?()
    }
}

extension ConnectRemoteNodeViewController: RemoteNodeCertificatesScannerDelegate {
    func didScanRemoteNodeCertificates(_ certificates: RemoteNodeCertificates) {
        self.certificates = certificates
    }
}

extension ConnectRemoteNodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
