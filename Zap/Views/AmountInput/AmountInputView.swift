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
    
    private var formattedAmount: String? {
        didSet {
            amountTextField.text = formattedAmount
            updateValidityIndicator()
            sendActions(for: .valueChanged)
        }
    }
    
    var validRange: ClosedRange<Satoshi>?
    var satoshis: Satoshi {
        get {
            guard let formattedAmount = formattedAmount else { return 0 }
            return Settings.primaryCurrency.value.satoshis(from: formattedAmount) ?? 0
        }
        set {
            guard let stringValue = Settings.primaryCurrency.value.stringValue(satoshis: newValue) else { return }
            
            if updateKeyPadString(input: stringValue) {
                keyPadView.numberString = stringValue
            }
        }
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
        
        amountTextField.textColor = UIColor.zap.text
        amountTextField.font = Font.light.withSize(36)
        amountTextField.placeholder = "Amount"
        amountTextField.inputView = UIView()
        amountTextField.delegate = self
        amountTextField.becomeFirstResponder()
        
        Style.button.apply(to: swapCurrencyButton)
        swapCurrencyButton.tintColor = UIColor.zap.text
        swapCurrencyButton.titleLabel?.font = Font.light.withSize(36)
        downArrowImageView.tintColor = UIColor.zap.text
        
        Settings.primaryCurrency
            .map { $0.symbol }
            .bind(to: swapCurrencyButton.reactive.title )
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func swapCurrencies(_ sender: Any) {
        let oldSatoshis = satoshis
        Settings.swapCurrencies()
        satoshis = oldSatoshis
    }
    
    private func setupKeyPad() {
        keyPadView.handler = updateKeyPadString
    }
    
    private func updateKeyPadString(input: String) -> Bool {
        let numberFormatter = InputNumberFormatter(currency: Settings.primaryCurrency.value)
        guard let output = numberFormatter.validate(input) else { return false }
        formattedAmount = output
        return true
    }
    
    private func updateValidityIndicator() {
        if formattedAmount != nil,
            let range = validRange {
            amountTextField.textColor = range.contains(satoshis) ? UIColor.zap.text : UIColor.zap.red
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
