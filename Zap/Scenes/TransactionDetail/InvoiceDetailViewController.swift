//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class InvoiceDetailViewController: UIViewController {
    @IBOutlet private weak var qrCodeContainer: UIView!
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var paymentRequestLabel: UILabel!
    @IBOutlet private weak var copyShareContainer: UIStackView!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var settledLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var settleDateLabel: UILabel!
    @IBOutlet private weak var expiryLabel: UILabel!
    
    var lightningInvoiceViewModel: LightningInvoiceViewModel?
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Invoice"
        titleTextStyle = .dark
        
        Style.label.apply(to: paymentRequestLabel, memoLabel, amountLabel, settledLabel, dateLabel, settleDateLabel, expiryLabel)
        Style.button.apply(to: copyButton, shareButton)
        
        updateViewModel()
    }
    
    private func updateViewModel() {
        guard let lightningInvoiceViewModel = lightningInvoiceViewModel else { return }
        let invoice = lightningInvoiceViewModel.lightningInvoice
        
        qrCodeImageView.image = UIImage.qrCode(from: invoice.paymentRequest)
        paymentRequestLabel.text = invoice.paymentRequest
        
        dateLabel.text = "Created: \(DateFormatter.localizedString(from: invoice.date, dateStyle: .medium, timeStyle: .short))"
        
        let isUnsettled = lightningInvoiceViewModel.state
            .map { $0 != .unsettled }
        
        [isUnsettled.bind(to: qrCodeContainer.reactive.isHidden),
         isUnsettled.bind(to: paymentRequestLabel.reactive.isHidden),
         isUnsettled.bind(to: copyShareContainer.reactive.isHidden)]
            .dispose(in: reactive.bag)
        
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
        
        if let expiry = formatedExpiry(for: invoice) {
            expiryLabel.text = "Expiry: \(expiry)"
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            if let expiry = self?.formatedExpiry(for: invoice) {
                self?.expiryLabel.text = "Expiry: \(expiry)"
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
    }
    
    private func formatedExpiry(for invoice: LightningInvoice) -> String? {
        let currentDate = Date()
        guard invoice.expiry >= currentDate else { return "Expired" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .brief
        formatter.maximumUnitCount = 3
        return formatter.string(from: currentDate, to: invoice.expiry)
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
