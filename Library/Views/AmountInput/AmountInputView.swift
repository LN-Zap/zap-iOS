//
//  Zap
//
//  Created by Otto Suess on 25.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import SwiftBTC
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
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var topViewBackground: UIView!
    @IBOutlet private weak var bottomViewBackground: UIView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var swapCurrencyButton: UIButton!
    @IBOutlet private weak var keyPadView: KeyPadView! {
        didSet {
            setupKeyPad()
        }
    }
    
    var isEditable: Bool = true
    
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
                bottomViewBackground.isHidden = true
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
    
    override public var backgroundColor: UIColor? {
        didSet {
            contentView?.backgroundColor = backgroundColor
            stackView?.backgroundColor = backgroundColor
            keyPadView?.backgroundColor = backgroundColor
            topViewBackground?.backgroundColor = backgroundColor
            bottomViewBackground?.backgroundColor = backgroundColor
        }
    }
    
    var textColor: UIColor = UIColor.Zap.black {
        didSet {
            amountTextField.textColor = textColor
            keyPadView.textColor = textColor
        }
    }
    
    override public init(frame: CGRect) {
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
        
        amountTextField.textColor = UIColor.Zap.black
        amountTextField.font = UIFont.Zap.light.withSize(36)
        amountTextField.placeholder = "view.amount_input.placeholder".localized
        amountTextField.inputView = UIView()
        amountTextField.delegate = self

        Style.Button.custom(color: UIColor.Zap.white, fontSize: 36).apply(to: swapCurrencyButton)
        
        Settings.shared.primaryCurrency
            .map { $0.symbol }
            .bind(to: swapCurrencyButton.reactive.title )
            .dispose(in: reactive.bag)        
    }
    
    @IBAction private func swapCurrencies(_ sender: Any) {
        let oldSatoshis = satoshis
        Settings.shared.swapCurrencies()
        
        if formattedAmount != nil && formattedAmount != "" {
            satoshis = oldSatoshis
        }
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
            amountTextField.textColor = range.contains(satoshis) ? textColor : UIColor.Zap.superRed
        }
    }
    
    @IBAction private func didSelectTextField(_ sender: Any) {
        guard !amountTextField.isFirstResponder else { return }
        becomeFirstResponder()
    }
    
    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        return amountTextField.becomeFirstResponder()
    }
    
    @discardableResult
    override public func resignFirstResponder() -> Bool {
        return amountTextField.resignFirstResponder()
    }
}

extension AmountInputView: UITextFieldDelegate {
    public func setKeypad(hidden: Bool, animated: Bool) {
        if animated {
            layoutIfNeeded()
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.bottomViewBackground.isHidden = hidden
                self?.layoutIfNeeded()
            }
        } else {
            bottomViewBackground.isHidden = hidden
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditable
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.amountInputViewDidBeginEditing(self)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.amountInputViewDidEndEditing(self)
    }
}
