//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import UIKit

public protocol AmountInputViewDelegate: class {
    func amountInputViewDidBeginEditing(_ amountInputView: AmountInputView)
    func amountInputViewDidEndEditing(_ amountInputView: AmountInputView)
}

public final class AmountInputView: UIControl {
    public enum AmountInputViewContext {
        case app
        case messages
    }
    
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
    @IBOutlet private weak var inputHeightConstraint: NSLayoutConstraint!
    
    public weak var delegate: AmountInputViewDelegate?
    
    private var formattedAmount: String? {
        didSet {
            amountTextField.text = formattedAmount
            updateValidityIndicator()
            sendActions(for: .valueChanged)
        }
    }
    
    public var context: AmountInputViewContext = .app {
        didSet {
            switch context {
            case .app:
                amountTextField.becomeFirstResponder()
            case .messages:
                keyPadHeightConstraint.constant = 0
            }
        }
    }
    
    public var validRange: ClosedRange<Satoshi>?
    public var satoshis: Satoshi {
        get {
            guard let formattedAmount = formattedAmount else { return 0 }
            return Settings.shared.primaryCurrency.value.satoshis(from: formattedAmount) ?? 0
        }
        set {
            guard let stringValue = Settings.shared.primaryCurrency.value.stringValue(satoshis: newValue) else { return }
            
            if updateKeyPadString(input: stringValue) {
                keyPadView.numberString = stringValue
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Bundle.library.loadNibNamed("AmountInputView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        amountTextField.textColor = UIColor.zap.black
        amountTextField.font = UIFont.zap.light.withSize(36)
        amountTextField.placeholder = "view.amount_input.placeholder".localized
        amountTextField.inputView = UIView()
        amountTextField.delegate = self
        
        Style.button.apply(to: swapCurrencyButton)
        swapCurrencyButton.tintColor = UIColor.zap.black
        swapCurrencyButton.titleLabel?.font = UIFont.zap.light.withSize(36)
        downArrowImageView.tintColor = UIColor.zap.black
        
        Settings.shared.primaryCurrency
            .map { $0.symbol }
            .bind(to: swapCurrencyButton.reactive.title )
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func swapCurrencies(_ sender: Any) {
        let oldSatoshis = satoshis
        Settings.shared.swapCurrencies()
        satoshis = oldSatoshis
    }
    
    private func setupKeyPad() {
        keyPadView.handler = { [weak self] in
            self?.updateKeyPadString(input: $0) ?? false
        }
    }
    
    private func updateKeyPadString(input: String) -> Bool {
        let numberFormatter = InputNumberFormatter(currency: Settings.shared.primaryCurrency.value)
        guard let output = numberFormatter.validate(input) else { return false }
        formattedAmount = output
        return true
    }
    
    private func updateValidityIndicator() {
        if formattedAmount != nil,
            let range = validRange {
            amountTextField.textColor = range.contains(satoshis) ? UIColor.zap.black : UIColor.zap.tomato
        }
    }
}

extension AmountInputView: UITextFieldDelegate {
    public func animateKeypad(hidden: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [keyPadHeightConstraint] in
            keyPadHeightConstraint?.constant = hidden ? 0 : 280
            }, completion: nil)
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.amountInputViewDidBeginEditing(self)
        animateKeypad(hidden: false)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.amountInputViewDidEndEditing(self)
        animateKeypad(hidden: true)
    }
}
