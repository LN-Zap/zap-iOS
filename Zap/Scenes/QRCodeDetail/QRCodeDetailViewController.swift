//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class QRCodeDetailViewController: UIViewController {
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var copyButton: UIButton!
    
    var viewModel: QRCodeDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let viewModel = viewModel else { fatalError("No ViewModel set.") }

        title = viewModel.title
        
        Style.label.apply(to: addressLabel) {
            $0.font = $0.font.withSize(14)
        }
        addressLabel?.textColor = Color.mediumBackground
        
        viewModel.address
            .observeNext { [weak self] address in
                switch address {
                case .loading:
                    break
                case .value(let address):
                    self?.updateAddress(address)
                }
            }
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func qrCodeTapped(_ sender: Any) {
        guard let address = viewModel?.address.value.value else { return }
        print(address)
        UIPasteboard.general.string = address
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func shareButtonTapped(_ sender: Any) {
        guard let address = viewModel?.address.value.value else { return }

        var items: [Any] = [address]
        
        if let image = qrCodeImageView.image {
            items.append(image)
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func updateAddress(_ address: String) {
        qrCodeImageView?.image = UIImage.qrCode(from: address)
        addressLabel?.text = address
    }
}
