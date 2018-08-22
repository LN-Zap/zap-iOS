//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import UIKit

extension UIStoryboard {
    static func instantiateQRCodeDetailViewController(with qrCodeDetailViewModel: QRCodeDetailViewModel) -> QRCodeDetailViewController {
        let viewController = Storyboard.qrCodeDetail.instantiate(viewController: QRCodeDetailViewController.self)
        viewController.viewModel = qrCodeDetailViewModel
        return viewController
    }
}

final class QRCodeDetailViewController: UIViewController {
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var requestMethodImageView: UIImageView!
    @IBOutlet private weak var requestMethodLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    
    fileprivate var viewModel: QRCodeDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewModel = viewModel else { fatalError("No ViewModel set.") }

        title = viewModel.title
        
        Style.Button.custom().apply(to: shareButton, copyButton)
        Style.Label.custom().apply(to: addressLabel)
        
        requestMethodLabel.font = UIFont.Zap.light.withSize(10)
        requestMethodLabel.tintColor = UIColor.Zap.black
        requestMethodImageView.tintColor = UIColor.Zap.black
        
        topView.backgroundColor = UIColor.Zap.white
        
        qrCodeImageView?.image = UIImage.qrCode(from: viewModel.paymentURI)
        
        addressLabel.text = viewModel.paymentURI.address
        
        updateRequestMethod()
    }
    
    @IBAction private func qrCodeTapped(_ sender: Any) {
        guard let address = viewModel?.paymentURI.uriString else { return }
        print(address)
        UIPasteboard.general.string = address
    }
    
    private func dismissParent() {
        if presentingViewController?.presentingViewController == nil {
            dismiss(animated: true, completion: nil)
        } else {
            // fixes the dismiss animation of two modals at once
            if let snapshotView = view.superview?.snapshotView(afterScreenUpdates: false) {
                presentingViewController?.view.addSubview(snapshotView)
            }
            view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismissParent()
    }
    
    @IBAction private func shareButtonTapped(_ sender: Any) {
        guard let address = viewModel?.paymentURI.uriString else { return }

        let items: [Any] = [address]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func updateRequestMethod() {
        if viewModel is LightningRequestQRCodeViewModel {
            requestMethodLabel.text = "scene.qr_code_detail.method_label.lightning".localized
            requestMethodImageView.image = UIImage(named: "icon-request-lightning", in: Bundle.library, compatibleWith: nil)
        } else if viewModel is OnChainRequestQRCodeViewModel {
            requestMethodLabel.text = "scene.qr_code_detail.method_label.on_chain".localized
            requestMethodImageView.image = UIImage(named: "icon-request-on-chain", in: Bundle.library, compatibleWith: nil)
        }
    }
}
