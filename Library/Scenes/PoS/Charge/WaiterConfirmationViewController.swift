//
//  Library
//
//  Created by Otto Suess on 04.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

extension UIStoryboard {
    static func instantiateWaiterConfirmationViewController(invoice: Invoice? = nil, transaction: SwiftLnd.Transaction? = nil) -> WaiterConfirmationViewController {
        let viewController = StoryboardScene.WalletInvoiceOnly.waiterConfirmationViewController.instantiate()
        
        viewController.invoice = invoice
        viewController.transaction = transaction
        
        return viewController
    }
}

final class WaiterConfirmationViewController: UIViewController {
    
    @IBOutlet private weak var primaryCurrencyLabel: UILabel!
    @IBOutlet private weak var secondaryCurrencyLabel: UILabel!
    @IBOutlet private weak var layerImageView: UIImageView!
    @IBOutlet private weak var layerLabel: UILabel!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    @IBOutlet private weak var confirmedLabel: UILabel!
    
    @IBOutlet private weak var thankYouLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!
    
    @IBOutlet private weak var stackView: UIStackView!
    
    fileprivate var invoice: Invoice?
    fileprivate var transaction: SwiftLnd.Transaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background
        
        primaryCurrencyLabel.textColor = .white
        
        secondaryCurrencyLabel.textColor = UIColor.Zap.gray
        
        layerImageView.tintColor = UIColor.Zap.lightningOrange
        
        layerLabel.textColor = UIColor.Zap.gray
        
        confirmedLabel.textColor = UIColor.Zap.superGreen
        confirmedLabel.text = "Paid and Confirmed."
        confirmedLabel.font = UIFont.Zap.light.withSize(40)
        
        thankYouLabel.textColor = UIColor.Zap.superGreen
        thankYouLabel.text = "Thank You!"
        
        Style.Button.background.apply(to: doneButton)
        doneButton.setTitle("Ok", for: .normal)

        stackView.setCustomSpacing(4, after: primaryCurrencyLabel)
        stackView.setCustomSpacing(9, after: secondaryCurrencyLabel)
        stackView.setCustomSpacing(6, after: layerImageView)
        stackView.setCustomSpacing(22, after: layerLabel)
        stackView.setCustomSpacing(14, after: checkmarkImageView)
        
        if let invoice = invoice {
            setup(invoice: invoice)
        } else if let transaction = transaction {
            setup(transaction: transaction)
        }
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setup(invoice: Invoice) {
        primaryCurrencyLabel.text = Settings.shared.primaryCurrency.value.format(satoshis: invoice.amount)
        secondaryCurrencyLabel.text = Settings.shared.secondaryCurrency.value.format(satoshis: invoice.amount)
        
        layerLabel.text = "via Lightning Network"
        layerImageView.image = Asset.tabbarWallet.image.withRenderingMode(.alwaysTemplate)
    }
    
    private func setup(transaction: SwiftLnd.Transaction) {
        primaryCurrencyLabel.text = Settings.shared.primaryCurrency.value.format(satoshis: transaction.amount)
        secondaryCurrencyLabel.text = Settings.shared.secondaryCurrency.value.format(satoshis: transaction.amount)
        
        layerLabel.text = "on-chain transaction"
        layerImageView.image = Asset.tabbarWallet.image.withRenderingMode(.alwaysTemplate)
    }
}
