//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class DetailQRCodeTableViewCell: UITableViewCell {
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    weak var delegate: UIViewController?
    
    var address: String? {
        didSet {
            guard let address = address else { return }
            qrCodeImageView.image = UIImage.qrCode(from: address)
            addressLabel.text = address
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        Style.label.apply(to: addressLabel)
        addressLabel.font = DetailCellType.dataFont
        Style.button.apply(to: copyButton, shareButton)
        
        copyButton.setTitle("scene.transaction_detail.qr_code.copy_button".localized, for: .normal)
        shareButton.setTitle("scene.transaction_detail.qr_code.share_button".localized, for: .normal)
    }
    
    @IBAction private func copyAddress(_ sender: Any) {
        guard let address = address else { return }
        print(address)
        UIPasteboard.general.string = address
    }
    
    @IBAction private func shareAddress(_ sender: Any) {
        guard let address = address else { return }
        let activityViewController = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        delegate?.present(activityViewController, animated: true, completion: nil)
    }
}
