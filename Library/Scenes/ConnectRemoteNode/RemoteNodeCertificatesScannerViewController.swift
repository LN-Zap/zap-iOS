//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateRemoteNodeCertificatesScannerViewController(connectRemoteNodeViewModel: ConnectRemoteNodeViewModel) -> RemoteNodeCertificatesScannerViewController {
        let viewController = StoryboardScene.ConnectRemoteNode.remoteNodeCertificatesScannerViewController.instantiate()
        viewController.connectRemoteNodeViewModel = connectRemoteNodeViewModel
        return viewController
    }
}

// swiftlint:disable:next type_name
final class RemoteNodeCertificatesScannerViewController: UIViewController {
    @IBOutlet private weak var navigationBar: UINavigationBar!
    
    fileprivate var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    
    @IBOutlet private weak var scannerView: QRCodeScannerView! {
        didSet {
            scannerView.handler = { [weak self] in
                self?.getConfigurationFrom(code: $0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func getConfigurationFrom(code: String) {
        RPCConnectQRCode.configuration(for: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let configuration):
                    self?.scannerView.stop()
                    self?.connectRemoteNodeViewModel?.remoteNodeConfiguration = configuration
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self?.presentErrorToast(error.localizedDescription)
                }
            }
        }
    }
}
