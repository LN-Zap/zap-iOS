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
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var topViewBackground: UIView!
    @IBOutlet private weak var bottomViewBackground: UIView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var amountSubtitleLabel: UILabel!
    @IBOutlet private weak var swapCurrencyButton: UIButton!
    @IBOutlet private weak var keyPadView: KeyPadView! {
        didSet {
            setupKeyPad()
        }
    }

    var isEditable: Bool = true

    public weak var delegate: AmountInputViewDelegate?

    private(set) var satoshis: Satoshi = 0 {
        didSet {
            sendActions(for: .valueChanged)
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

    override public var isEnabled: Bool {
        didSet {
            keyPadView.isEnabled = isEnabled
        }
    }

    var textColor: UIColor = UIColor.Zap.black {
        didSet {
            amountTextField.textColor = textColor
            keyPadView.textColor = textColor
        }
    }

    var subtitleText: String? {
        didSet {
            amountSubtitleLabel.text = subtitleText
        }
    }
    var subtitleTextColor: UIColor = UIColor.white {
        didSet {
            amountSubtitleLabel.textColor = subtitleTextColor
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
        amountTextField.placeholder = L10n.View.AmountInput.placeholder
        amountTextField.inputView = UIView()
        amountTextField.delegate = self

        amountSubtitleLabel.text = nil

        Style.Button.custom(color: UIColor.Zap.white, fontSize: 36).apply(to: swapCurrencyButton)

        Settings.shared.primaryCurrency
            .map { $0.symbol }
            .bind(to: swapCurrencyButton.reactive.title )
            .dispose(in: reactive.bag)
    }

    func updateAmount(_ amount: Satoshi) {
        self.satoshis = amount
        updateTextFieldContent()
    }

    private func updateTextFieldContent() {
        guard let stringValue = Settings.shared.primaryCurrency.value.stringValue(satoshis: satoshis) else { return }
        keyPadView.numberString = stringValue

        let numberFormatter = InputNumberFormatter(currency: Settings.shared.primaryCurrency.value)
        amountTextField.text = numberFormatter.validate(stringValue)
    }

    @IBAction private func swapCurrencies(_ sender: Any) {
        Settings.shared.swapCurrencies()
        updateTextFieldContent()
    }

    private func setupKeyPad() {
        keyPadView.handler = { [weak self] in
            self?.updateKeyPadString(input: $0) ?? false
        }
    }

    private func updateKeyPadString(input: String) -> Bool {
        let numberFormatter = InputNumberFormatter(currency: Settings.shared.primaryCurrency.value)
        guard let output = numberFormatter.validate(input) else { return false }
        amountTextField.text = output
        self.satoshis = Settings.shared.primaryCurrency.value.satoshis(from: output) ?? 0

        return true
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
                guard let self = self else { return }
                self.bottomViewBackground.isHidden = hidden
                self.layoutIfNeeded()
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
