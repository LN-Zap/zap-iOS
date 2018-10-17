//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import SwiftBTC
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
        
        title = viewModel.title
        view.backgroundColor = UIColor.Zap.background
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        Style.Button.background.apply(to: shareButton, copyButton)
        
        qrCodeImageView?.image = UIImage.qrCode(from: viewModel.paymentURI)
        
        contentStackView.spacing = 10
        let tableFontStyle = Style.Label.footnote
        let tableLabelSpacing: CGFloat = 0
        
        if let amount = viewModel.paymentURI.amount, amount != 0 {
            contentStackView.addArrangedElement(.verticalStackView(content: [
                .label(text: "scene.transaction_detail.amount_label".localized + ":", style: tableFontStyle),
                .amountLabel(amount: amount, style: tableFontStyle)
            ], spacing: tableLabelSpacing))
            contentStackView.addArrangedElement(.separator)
        }
        
        if let memo = viewModel.paymentURI.memo, !memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            contentStackView.addArrangedElement(.verticalStackView(content: [
                .label(text: "scene.transaction_detail.memo_label".localized + ":", style: tableFontStyle),
                .label(text: memo, style: tableFontStyle)
            ], spacing: tableLabelSpacing))
            contentStackView.addArrangedElement(.separator)
        }
        
        contentStackView.addArrangedElement(.verticalStackView(content: [
            .label(text: "scene.transaction_detail.address_label".localized + ":", style: tableFontStyle),
            .label(text: viewModel.paymentURI.address, style: tableFontStyle)
        ], spacing: tableLabelSpacing))
        
        shareButton.setTitle("generic.qr_code.share_button".localized, for: .normal)
        copyButton.setTitle("generic.qr_code.copy_button".localized, for: .normal)
    }
    
    @IBAction private func qrCodeTapped(_ sender: Any) {
        guard let address = viewModel?.paymentURI.uriString else { return }
        print(address)
        
        let toast = Toast(message: "generic.qr_code.copy_success_message".localized, style: .success)
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
        guard let address = viewModel?.paymentURI.uriString else { return }

        let items: [Any] = [address]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
