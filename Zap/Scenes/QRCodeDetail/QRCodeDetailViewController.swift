//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class QRCodeDetailViewController: UIViewController {
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var requestMethodImageView: UIImageView!
    @IBOutlet private weak var requestMethodLabel: UILabel!
    
    var viewModel: QRCodeDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewModel = viewModel else { fatalError("No ViewModel set.") }

        title = viewModel.title
        
        requestMethodLabel.font = Font.light.withSize(10)
        requestMethodLabel.tintColor = Color.text
        requestMethodImageView.tintColor = Color.text
        
        topView.backgroundColor = Color.searchBackground
        
        qrCodeImageView?.image = UIImage.qrCode(from: viewModel.address)
        
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

        var items: [Any] = [address]
        
        if let image = qrCodeImageView.image {
            items.append(image)
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func updateRequestMethod() {
        if viewModel is LightningRequestQRCodeViewModel {
            requestMethodLabel.text = "Lightning"
        } else if viewModel is OnChainRequestQRCodeViewModel {
            requestMethodLabel.text = "On-chain"
        }
    }
}
