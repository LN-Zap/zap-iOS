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
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var requestMethodImageView: UIImageView!
    @IBOutlet private weak var requestMethodLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    
    fileprivate var viewModel: QRCodeDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewModel = viewModel else { fatalError("No ViewModel set.") }

        title = viewModel.title
        
        Style.button.apply(to: shareButton, copyButton)
        Style.label.apply(to: addressLabel)
        
        requestMethodLabel.font = UIFont.zap.light.withSize(10)
        requestMethodLabel.tintColor = UIColor.zap.text
        requestMethodImageView.tintColor = UIColor.zap.text
        
        topView.backgroundColor = UIColor.zap.searchBackground
        
        qrCodeImageView?.image = UIImage.qrCode(from: viewModel.address)
        
        addressLabel.text = viewModel.address.replacingOccurrences(of: "bitcoin:", with: "").replacingOccurrences(of: "lightning:", with: "")
        
        updateRequestMethod()
    }
    
    @IBAction private func qrCodeTapped(_ sender: Any) {
        guard let address = viewModel?.address else { return }
        print(address)
        UIPasteboard.general.string = address
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func shareButtonTapped(_ sender: Any) {
        guard let address = viewModel?.address else { return }

        let items: [Any] = [address]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func updateRequestMethod() {
        if viewModel is LightningRequestQRCodeViewModel {
            requestMethodLabel.text = "Lightning"
            requestMethodImageView.image = #imageLiteral(resourceName: "icon-request-lightning")
        } else if viewModel is OnChainRequestQRCodeViewModel {
            requestMethodLabel.text = "On-chain"
            requestMethodImageView.image = #imageLiteral(resourceName: "icon-request-on-chain")
        }
    }
}
