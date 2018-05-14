//
//  Zap
//
//  Created by Otto Suess on 06.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class TransactionDetailViewController: UIViewController {
    @IBOutlet private weak var feesLabel: UILabel!
    @IBOutlet private weak var confirmationsLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    var transactionViewModel: OnChainTransactionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextStyle = .dark
        title = "Transaction Detail"
        
        Style.label.apply(to: feesLabel, confirmationsLabel, addressLabel, amountLabel, dateLabel)
        
        updateTransaction()
    }
    
    private func updateTransaction() {
        guard let transaction = transactionViewModel?.onChainTransaction else { return }
        
        confirmationsLabel.text = "Confirmations: \(transaction.confirmations)"
        
        let feesString = Settings.primaryCurrency.value.format(satoshis: transaction.fees) ?? "0"
        feesLabel.text = "Fees: \(feesString)"
        
        addressLabel.text = transaction.firstDestinationAddress
        amountLabel.text = Settings.primaryCurrency.value.format(satoshis: transaction.amount)
        dateLabel.text = DateFormatter.localizedString(from: transaction.date, dateStyle: .medium, timeStyle: .short)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
