//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SendLightningInvoiceViewController: UIViewController, QRCodeScannerChildViewController {
    @IBOutlet private weak var paymentRequestView: UIStackView!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var secondaryAmountLabel: UILabel!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var paymentBackground: UIView!
    @IBOutlet private weak var destinationLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    var sendViewModel: SendLightningInvoiceViewModel?
    let contentHeight: CGFloat = 380 // QRCodeScannerChildViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Style.button.apply(to: sendButton)
        Style.label.apply(to: memoLabel, amountLabel, secondaryAmountLabel, destinationLabel)
        amountLabel.font = amountLabel.font.withSize(36)
        secondaryAmountLabel.font = amountLabel.font.withSize(14)
        secondaryAmountLabel.textColor = .gray
        
        arrowImageView.tintColor = Color.text
        
        [sendViewModel?.memo.bind(to: memoLabel.reactive.text),
         sendViewModel?.satoshis.bind(to: amountLabel.reactive.text, currency: Settings.primaryCurrency),
         sendViewModel?.destination.bind(to: destinationLabel.reactive.text),
         sendViewModel?.satoshis.bind(to: secondaryAmountLabel.reactive.text, currency: Settings.secondaryCurrency)]
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        sendViewModel?.send { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
