//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import UIKit

final class DetailQRCodeTableViewCell: UITableViewCell {
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    weak var delegate: UIViewController?
    
    var paymentURI: PaymentURI? {
        didSet {
            guard let paymentURI = paymentURI else { return }
            qrCodeImageView.image = UIImage.qrCode(from: paymentURI)
            addressLabel.text = paymentURI.uriString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        DetailCellType.dataFontStyle.apply(to: addressLabel)
        Style.Button.custom().apply(to: copyButton, shareButton)
        
        copyButton.setTitle("generic.qr_code.copy_button".localized, for: .normal)
        shareButton.setTitle("generic.qr_code.share_button".localized, for: .normal)
        
        backgroundColor = .clear
    }
    
    @IBAction private func copyAddress(_ sender: Any) {
        guard let uriString = paymentURI?.uriString else { return }
        print(uriString)
        UIPasteboard.general.string = uriString
    }
    
    @IBAction private func shareAddress(_ sender: Any) {
        guard let uriString = paymentURI?.uriString else { return }
        let activityViewController = UIActivityViewController(activityItems: [uriString], applicationActivities: nil)
        delegate?.present(activityViewController, animated: true, completion: nil)
    }
}
