//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class LightningRequestViewController: UIViewController {
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var placeholderTextView: UITextView!
    @IBOutlet private weak var memoTextView: UITextView!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var amountInputView: UIView!
    @IBOutlet private weak var swapCurrencyButton: UIButton!
    @IBOutlet private weak var downArrowImageView: UIImageView!
    
    var lightningRequestViewModel: LightningRequestViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "scene.request.title".localized
        
        amountTextField.textColor = Color.text
        amountTextField.font = Font.light.withSize(36)
        amountTextField.placeholder = "Amount"
        amountTextField.inputView = UIView()
        amountTextField.delegate = self
        amountTextField.becomeFirstResponder()
        
        Style.button.apply(to: createButton)
        createButton.setTitle("Generate  Request", for: .normal)
        createButton.tintColor = .white
        
        placeholderTextView.text = "Memo (optional)"
        placeholderTextView.font = Font.light.withSize(14)
        placeholderTextView.textColor = Color.disabled
        memoTextView.font = Font.light.withSize(14)
        memoTextView.textColor = Color.text
        
        Style.button.apply(to: swapCurrencyButton)
        swapCurrencyButton.tintColor = Color.text
        swapCurrencyButton.titleLabel?.font = Font.light.withSize(36)
        downArrowImageView.tintColor = Color.text

        Settings.primaryCurrency
            .map { $0.symbol }
            .bind(to: swapCurrencyButton.reactive.title )
            .dispose(in: reactive.bag)
        
        lightningRequestViewModel?.amountString
            .bind(to: amountTextField.reactive.text)
            .dispose(in: reactive.bag)
        
        lightningRequestViewModel?.isAmountValid
            .map { $0 ? Color.text : Color.red }
            .bind(to: amountTextField.reactive.textColor)
            .dispose(in: reactive.bag)
        
        memoTextView.reactive.text
            .map { !($0?.isEmpty ?? true) }
            .bind(to: placeholderTextView.reactive.isHidden )
            .dispose(in: reactive.bag)
        
        memoTextView.reactive.text
            .observeNext { [lightningRequestViewModel] text in
                lightningRequestViewModel?.memo = text
            }
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func createButtonTapped(_ sender: Any) {
//        lightningRequestViewModel?.create { [weak self] string in
//            self?.performSegue(withIdentifier: "showQRCodeDetailViewController", sender: string)
//        }
    }
    
    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.swapCurrencies()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let numericKeyPad = segue.destination as? NumericKeyPadViewController else { return }
        let numberFormatter = InputNumberFormatter(unit: .bit)
        
        numericKeyPad.handler = { [weak self] input in
            guard let output = numberFormatter.validate(input) else { return false }
            
            self?.lightningRequestViewModel?.updateAmount(output)
            return true
        }
    }
}

extension LightningRequestViewController: UITextFieldDelegate {
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
