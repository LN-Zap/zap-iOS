//
//  Zap
//
//  Created by Otto Suess on 06.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class TransactionDetailViewController: UIViewController {
    @IBOutlet private weak var confirmationsTitleLabel: UILabel!
    @IBOutlet private weak var confirmationsLabel: UILabel!
    
    var transactionViewModel: TransactionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transaction Detail"
        
        Style.label.apply(to: confirmationsLabel,
                          confirmationsTitleLabel)
        
        confirmationsTitleLabel.text = "Confirmations:"
        
        updateTransaction()
    }
    
    private func updateTransaction() {
        guard let transaction = transactionViewModel?.transaction as? BlockchainTransaction else { return }
        
        confirmationsLabel.text = String(transaction.confirmations)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
