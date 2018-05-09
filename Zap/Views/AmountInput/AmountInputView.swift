//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import UIKit

class AmountInputView: UIControl {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var swapCurrencyButton: UIButton!
    @IBOutlet private weak var downArrowImageView: UIImageView!
    @IBOutlet private weak var keyPadView: KeyPadView! {
        didSet {
            setupKeyPad()
        }
    }
    @IBOutlet private weak var keyPadHeightConstraint: NSLayoutConstraint!
    
    var amountString: String? {
        didSet {
            amountTextField.text = amountString
            if amountString != nil, let range = validRange {
                amountTextField.textColor = range.contains(satoshis) ? Color.text : Color.red
            }
            sendActions(for: .valueChanged)
        }
    }
    
    var validRange: ClosedRange<Satoshi>?
    var satoshis: Satoshi {
        guard let amountString = amountString else { return 0 }
        return Satoshi.from(string: amountString, unit: .bit) ?? 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("AmountInputView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        amountTextField.textColor = Color.text
        amountTextField.font = Font.light.withSize(36)
        amountTextField.placeholder = "Amount"
        amountTextField.inputView = UIView()
        amountTextField.delegate = self
        amountTextField.becomeFirstResponder()
        
        Style.button.apply(to: swapCurrencyButton)
        swapCurrencyButton.tintColor = Color.text
        swapCurrencyButton.titleLabel?.font = Font.light.withSize(36)
        downArrowImageView.tintColor = Color.text
        
        Settings.primaryCurrency
            .map { $0.symbol }
            .bind(to: swapCurrencyButton.reactive.title )
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func swapCurrencies(_ sender: Any) {
        Settings.swapCurrencies()
    }
    
    private func setupKeyPad() {
        let numberFormatter = InputNumberFormatter(unit: .bit)
        
        keyPadView.handler = { [weak self] input in
            guard let output = numberFormatter.validate(input) else { return false }
            self?.amountString = output
            return true
        }
    }
}

extension AmountInputView: UITextFieldDelegate {
    private func animateKeypad(hidden: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [keyPadHeightConstraint] in
            keyPadHeightConstraint?.constant = hidden ? 0 : 280
            }, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateKeypad(hidden: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateKeypad(hidden: true)
    }
}
