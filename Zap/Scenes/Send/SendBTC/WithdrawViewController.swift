//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class WithdrawViewController: UIViewController, QRCodeScannerChildViewController {
    
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var amountInputView: AmountInputView!

    let contentHeight: CGFloat = 550 // QRCodeScannerChildViewController
    var withdrawViewModel: WithdrawViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.withdraw.title".localized
        
        Style.label.apply(to: addressLabel)
        Style.button.apply(to: sendButton)
        sendButton.tintColor = .white
        
        addressLabel.text = withdrawViewModel?.address
        
        amountInputView.validRange = withdrawViewModel?.validRange
    }
    
    @IBAction private func updateAmount(_ sender: Any) {
        withdrawViewModel?.amount = amountInputView.satoshis
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        withdrawViewModel?.send { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
