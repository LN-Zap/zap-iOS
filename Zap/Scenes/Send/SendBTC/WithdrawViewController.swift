//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class WithdrawViewController: UIViewController {
    
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var allButton: UIButton!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var amountTextField: UITextField!

    var withdrawViewModel: WithdrawViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.withdraw.title".localized
        amountTextField?.keyboardType = .decimalPad
        
        Style.label.apply(to: addressLabel)
        Style.button.apply(to: allButton, sendButton)
        sendButton.tintColor = .white
        
        addressLabel.text = withdrawViewModel?.address
        
        withdrawViewModel?.amount
            .map { $0.format(unit: .bit) }
            .bind(to: amountTextField.reactive.text)
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func sendButtonTapped(_ sender: Any) {
        withdrawViewModel?.send()
    }
    
    @IBAction private func allButtonTapped(_ sender: Any) {
        withdrawViewModel?.selectAll()
    }
}
