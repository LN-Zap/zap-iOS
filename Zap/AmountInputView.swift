//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

protocol AmountInputtable {
    var amountString: Observable<String?> { get }
    var isAmountValid: Observable<Bool> { get }
    
    func updateAmount(_ amount: String?)
}

class AmountInputView: UIView {
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var amountInputView: UIView!
    @IBOutlet private weak var swapCurrencyButton: UIButton!
    @IBOutlet private weak var downArrowImageView: UIImageView!
    @IBOutlet private weak var keyPadView: KeyPadView!
    
    var amountViewModel: AmountInputtable? {
        didSet {
            setupBindings()
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
    }
    
    private func setupBindings() {
        Settings.primaryCurrency
            .map { $0.symbol }
            .bind(to: swapCurrencyButton.reactive.title )
            .dispose(in: reactive.bag)
        
        amountViewModel?.amountString
            .bind(to: amountTextField.reactive.text)
            .dispose(in: reactive.bag)
        
        amountViewModel?.isAmountValid
            .map { $0 ? Color.text : Color.red }
            .bind(to: amountTextField.reactive.textColor)
            .dispose(in: reactive.bag)
        
        setupKeyPad()
    }
    
    @IBAction private func swapCurrencies(_ sender: Any) {
        Settings.swapCurrencies()
    }
    
    private func setupKeyPad() {
        let numberFormatter = InputNumberFormatter(unit: .bit)
        
        keyPadView.handler = { [weak self] input in
            guard let output = numberFormatter.validate(input) else { return false }
            self?.amountViewModel?.updateAmount(output)
            return true
        }
    }
}

extension AmountInputView: UITextFieldDelegate {
    private func animateKeypad(hidden: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [amountInputView] in
            amountInputView?.isHidden = hidden
            }, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateKeypad(hidden: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateKeypad(hidden: true)
    }
}
