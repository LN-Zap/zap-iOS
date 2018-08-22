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
    @IBOutlet private weak var addressLabel: UILabel!
    
    fileprivate var viewModel: QRCodeDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewModel = viewModel else { fatalError("No ViewModel set.") }

        view.addBackgroundGradient()
        
        title = viewModel.title
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        Style.Button.background.apply(to: shareButton, copyButton)
        Style.Label.body.with({ $0.numberOfLines = 0 }).apply(to: addressLabel)
        
        qrCodeImageView?.image = UIImage.qrCode(from: viewModel.paymentURI)
        
        addressLabel.text = viewModel.paymentURI.address
        
        shareButton.setTitle("generic.qr_code.share_button".localized, for: .normal)
        copyButton.setTitle("generic.qr_code.copy_button".localized, for: .normal)
    }
    
    @IBAction private func qrCodeTapped(_ sender: Any) {
        guard let address = viewModel?.paymentURI.uriString else { return }
        print(address)
        UISelectionFeedbackGenerator().selectionChanged()
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
}
