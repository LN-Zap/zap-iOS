//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateRemoteNodeCertificatesScannerViewController(with delegate: RemoteNodeCertificatesScannerDelegate) -> RemoteNodeCertificatesScannerViewController {
        let viewController = Storyboard.connectRemoteNode.instantiate(viewController: RemoteNodeCertificatesScannerViewController.self)
        viewController.delegate = delegate
        return viewController
    }
}

protocol RemoteNodeCertificatesScannerDelegate: class {
    func didScanRemoteNodeCertificates(_: RemoteNodeCertificates)
}

// swiftlint:disable:next type_name
class RemoteNodeCertificatesScannerViewController: UIViewController {
    @IBOutlet private weak var cancelButton: UIButton!
    
    fileprivate weak var delegate: RemoteNodeCertificatesScannerDelegate?
    
    @IBOutlet private weak var scannerView: QRCodeScannerView! {
        didSet {
            scannerView.remoteNodeCertificateHandler = { [weak self] in
                self?.delegate?.didScanRemoteNodeCertificates($0)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.button.apply(to: cancelButton)
    }
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
