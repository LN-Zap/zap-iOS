//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ConnectRemoteNodeViewController: UIViewController {
    
    @IBOutlet private weak var ipTextField: UITextField!
    
    @IBOutlet private weak var certLabel: UILabel!
    @IBOutlet private weak var addCertificatesButton: UIButton!
    
    @IBOutlet private weak var connectButton: UIButton!
    
    private var certificates: RemoteNodeCertificates? = RemoteNodeCertificates.debug
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Connect Remote Node"
        
        view.backgroundColor = Color.darkBackground
        
        Style.label.apply(to: certLabel) {
            $0.textColor = .white
        }
        Style.textField.apply(to: ipTextField) {
            $0.textColor = .white
        }
        Style.button.apply(to: addCertificatesButton, connectButton)
        
        ipTextField.attributedPlaceholder =
            NSAttributedString(string: "192.168.1.3", attributes: [.foregroundColor: UIColor.lightGray])
        
        certLabel.text = "🅾️"
        
        addCertificatesButton.setTitle("scan certificates", for: .normal)
        connectButton.setTitle("Connect", for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? RemoteNodeCertificatesScannerViewController {
            viewController.delegate = self
        }
    }
    
    @IBAction private func connectRemoteNode(_ sender: Any) {
        print("connect to remote")
    }
}

extension ConnectRemoteNodeViewController: RemoteNodeCertificatesScannerDelegate {
    func didScanRemoteNodeCertificates(_ certificates: RemoteNodeCertificates) {
        self.certificates = certificates
        certLabel.text = "✅"
    }
}
