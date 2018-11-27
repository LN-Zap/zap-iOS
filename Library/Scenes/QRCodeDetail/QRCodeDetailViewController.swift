//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

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
    @IBOutlet private weak var contentStackView: UIStackView!
    
    fileprivate var viewModel: QRCodeDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewModel = viewModel else { fatalError("No ViewModel set.") }
        
        if viewModel is NodeURIQRCodeViewModel {
            navigationItem.rightBarButtonItem = nil
        }
        
        title = viewModel.title
        view.backgroundColor = UIColor.Zap.background
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        Style.Button.background.apply(to: shareButton, copyButton)
        
        qrCodeImageView?.image = UIImage.qrCode(from: viewModel.qrCodeString)
        
        contentStackView.spacing = 10
        contentStackView.set(elements: viewModel.detailConfiguration)
        
        shareButton.setTitle(L10n.Generic.QrCode.shareButton, for: .normal)
        copyButton.setTitle(L10n.Generic.QrCode.copyButton, for: .normal)
    }
    
    @IBAction private func qrCodeTapped(_ sender: Any) {
        guard let address = viewModel?.uriString else { return }
        print(address)
        
        let toast = Toast(message: L10n.Generic.QrCode.copySuccessMessage, style: .success)
        presentToast(toast, animated: true, completion: nil)
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
        guard let address = viewModel?.uriString else { return }

        let items: [Any] = [address]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
