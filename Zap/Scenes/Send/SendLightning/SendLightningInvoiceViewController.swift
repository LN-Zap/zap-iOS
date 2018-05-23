//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SendLightningInvoiceViewController: UIViewController, QRCodeScannerChildViewController {
    weak var delegate: QRCodeScannerChildDelegate?
    
    @IBOutlet private weak var paymentRequestView: UIStackView!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var secondaryAmountLabel: UILabel!
    @IBOutlet private weak var paymentBackground: UIView!
    @IBOutlet private weak var destinationLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var gradientButtonView: GradientLoadingButtonView!
    @IBOutlet private weak var expiredView: UIView!
    @IBOutlet private weak var expiredLabel: UILabel!
    
    var sendViewModel: SendLightningInvoiceViewModel?
    let contentHeight: CGFloat = 380 // QRCodeScannerChildViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.label.apply(to: memoLabel, amountLabel, secondaryAmountLabel, destinationLabel, expiredLabel)
        amountLabel.font = amountLabel.font.withSize(36)
        secondaryAmountLabel.font = amountLabel.font.withSize(14)
        secondaryAmountLabel.textColor = .gray
        
        gradientButtonView.title = "Send"
        
        expiredView.backgroundColor = UIColor.zap.red
        expiredLabel.textColor = .white
        
        arrowImageView.tintColor = UIColor.zap.text
        
        [sendViewModel?.memo.bind(to: memoLabel.reactive.text),
         sendViewModel?.satoshis.bind(to: amountLabel.reactive.text, currency: Settings.primaryCurrency),
         sendViewModel?.destination.bind(to: destinationLabel.reactive.text),
         sendViewModel?.satoshis.bind(to: secondaryAmountLabel.reactive.text, currency: Settings.secondaryCurrency),
         sendViewModel?.invoiceError
            .map({ (error: SendLightningInvoiceError) -> Bool in
                switch error {
                case .none:
                    return true
                default:
                    return false
                }
            })
            .observeOn(DispatchQueue.main)
            .observeNext(with: { [weak self] in
                self?.expiredView.isHidden = $0
                self?.gradientButtonView.isHidden = !$0
            }),
         sendViewModel?.invoiceError
            .map({ (error: SendLightningInvoiceError) -> String? in
                switch error {
                    
                case .none:
                    return nil
                case .expired(let date):
                    return "Payment Request expired:\n\(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))"
                case .duplicate:
                    return "Payment already paid."
                }
            })
            .ignoreNil()
            .bind(to: expiredLabel.reactive.text)]
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        sendViewModel?.send { [weak self] _ in
            self?.delegate?.dismissSuccessfully()
        }
    }
}
