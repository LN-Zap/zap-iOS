//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class InvoiceDetailViewController: UIViewController {

    @IBOutlet weak private var qrCodeImageView: UIImageView!
    @IBOutlet weak private var paymentRequestLabel: UILabel!
    @IBOutlet weak private var copyButton: UIButton!
    @IBOutlet weak private var shareButton: UIButton!
    @IBOutlet weak private var memoLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var settledLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var settleDateLabel: UILabel!
    @IBOutlet weak private var expiryLabel: UILabel!
    
    var lightningInvoiceViewModel: LightningInvoiceViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Invoice"
        titleTextStyle = .dark
        
        Style.label.apply(to: paymentRequestLabel, memoLabel, amountLabel, settledLabel, dateLabel, settleDateLabel, expiryLabel)
        Style.button.apply(to: copyButton, shareButton)
        
        updateViewModel()
    }
    
    private func updateViewModel() {
        guard let invoice = lightningInvoiceViewModel?.lightningInvoice else { return }
        
        qrCodeImageView.image = UIImage.qrCode(from: invoice.paymentRequest)
        paymentRequestLabel.text = invoice.paymentRequest
        
        dateLabel.text = "Created: \(DateFormatter.localizedString(from: invoice.date, dateStyle: .medium, timeStyle: .short))"
        
        if !invoice.memo.isEmpty {
            memoLabel.text = invoice.memo
        } else {
            memoLabel.isHidden = true
        }
        
        if invoice.amount > 0,
            let amountString = Settings.primaryCurrency.value.format(satoshis: invoice.amount) {
            amountLabel.text = "Amount: \(amountString)"
        } else {
            amountLabel.text = "Amount: Unspecified"
        }
        
        settledLabel.text = invoice.settled ? "Settled" : "Unsettled"
        
        if let settleDate = invoice.settleDate {
            settleDateLabel.text = DateFormatter.localizedString(from: settleDate, dateStyle: .medium, timeStyle: .short)
        } else {
            settleDateLabel.isHidden = true
        }
        
        expiryLabel.text = "Expiry: \(DateFormatter.localizedString(from: invoice.expiry, dateStyle: .medium, timeStyle: .short))"
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func copyPaymentRequest(_ sender: Any) {
        guard let paymentRequest = lightningInvoiceViewModel?.lightningInvoice.paymentRequest else { return }
        print(paymentRequest)
        UIPasteboard.general.string = paymentRequest
    }
    
    @IBAction private func sharePaymentRequest(_ sender: Any) {
        guard let paymentRequest = lightningInvoiceViewModel?.lightningInvoice.paymentRequest else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [paymentRequest], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
