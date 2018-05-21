//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ConnectRemoteNodeViewController: UIViewController {
    
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var zapconnectLabel: UILabel!
    @IBOutlet private weak var scanCertificatesButton: UIButton!
    @IBOutlet private weak var pasteCertificatesButton: UIButton!
    
    @IBOutlet private weak var connectButton: UIButton!
    @IBOutlet private weak var textView: UITextView!
    
    private var certificates: RemoteNodeCertificates? {
        didSet {
            updateCertificatesUI()
        }
    }
    
    var connectCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Connect Remote Node"
        
        view.backgroundColor = Color.darkBackground
        
        Style.label.apply(to: zapconnectLabel)
        zapconnectLabel.textColor = .white
        Style.textField.apply(to: urlTextField) {
            $0.textColor = .white
        }
        Style.button.apply(to: scanCertificatesButton, pasteCertificatesButton, connectButton)
        
        urlTextField.attributedPlaceholder =
            NSAttributedString(string: "192.168.1.3:10011", attributes: [.foregroundColor: UIColor.lightGray])
        urlTextField.delegate = self
        
        scanCertificatesButton.setTitle("scan", for: .normal)
        pasteCertificatesButton.setTitle("paste", for: .normal)
        connectButton.setTitle("Connect", for: .normal)
        
        textView.font = UIFont(name: "Courier", size: 12)
        textView.backgroundColor = .clear
        textView.textColor = .white
        
        let configuration = RemoteNodeConfiguration.load()
        certificates = configuration?.remoteNodeCertificates
        urlTextField.text = configuration?.url.absoluteString ?? "192.168.1.3:10011"
    }
    
    private func updateCertificatesUI() {
        let certString: String = certificates?.certificate ?? "no cert"
        let macString: String = certificates?.macaron.base64EncodedString() ?? "no mac"
        
        textView.text = "\(certString)\n\n\(macString)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? RemoteNodeCertificatesScannerViewController {
            viewController.delegate = self
        }
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
        connectCallback?()
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
