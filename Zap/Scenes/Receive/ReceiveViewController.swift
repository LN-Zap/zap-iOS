//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class ReceiveViewController: ModalViewController {
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var placeholderTextView: UITextView!
    @IBOutlet private weak var memoTextView: UITextView!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var amountInputView: UIView!
    @IBOutlet private weak var swapCurrencyButton: UIButton!
    @IBOutlet private weak var downArrowImageView: UIImageView!
    
    var viewModel: ViewModel?
    private var createReceiveViewModel: CreateReceiveViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel else { return }
        
        title = "scene.receive.title".localized
        
        self.createReceiveViewModel = CreateReceiveViewModel(viewModel: viewModel)
        
        amountTextField.textColor = Color.textColor
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
        placeholderTextView.textColor = Color.disabledColor
        memoTextView.font = Font.light.withSize(14)
        memoTextView.textColor = Color.textColor
        
        Style.button.apply(to: swapCurrencyButton)
        swapCurrencyButton.tintColor = Color.textColor
        swapCurrencyButton.titleLabel?.font = Font.light.withSize(36)
        downArrowImageView.tintColor = Color.textColor

        Settings.primaryCurrency
            .map { $0.symbol }
            .bind(to: swapCurrencyButton.reactive.title )
            .dispose(in: reactive.bag)
        
        createReceiveViewModel?.amountString
            .bind(to: amountTextField.reactive.text)
            .dispose(in: reactive.bag)
        
        createReceiveViewModel?.isAmountValid
            .map { $0 ? Color.textColor : Color.red }
            .bind(to: amountTextField.reactive.textColor)
            .dispose(in: reactive.bag)
        
        memoTextView.reactive.text
            .map { !($0?.isEmpty ?? true) }
            .bind(to: placeholderTextView.reactive.isHidden )
            .dispose(in: reactive.bag)
        
        memoTextView.reactive.text
            .observeNext { [weak self] text in
                self?.createReceiveViewModel?.memo = text
            }
            .dispose(in: reactive.bag)
        
        setupKeyboardNotifications()
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.reactive.notification(name: .UIKeyboardWillHide)
            .observeNext { [weak self] _ in
                if let presetation = self?.navigationController?.presentationController as? ModalPresentationController {
                    let newHeight = UIScreen.main.bounds.height * 0.75
                    let newY = UIScreen.main.bounds.height - newHeight
                    let newWidth = UIScreen.main.bounds.width
                    presetation.animateFrame(to: CGRect(x: 0, y: newY, width: newWidth, height: newHeight))
                }
            }
            .dispose(in: reactive.bag)
        
        NotificationCenter.default.reactive.notification(name: .UIKeyboardWillShow)
            .observeNext { [weak self] notification in
                guard
                    let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
                    else { return }
                
                if let presentation = self?.navigationController?.presentationController as? ModalPresentationController {
                    let newHeight = keyboardFrame.minY
                    let newWidth = UIScreen.main.bounds.width
                    presentation.animateFrame(to: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
                }
            }
            .dispose(in: reactive.bag)
    }
    
    @IBAction private func createButtonTapped(_ sender: Any) {
        createReceiveViewModel?.create { [weak self] string in
            self?.performSegue(withIdentifier: "showQRCodeDetailViewController", sender: string)
        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.swapCurrencies()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let qrCodeDetailViewController = segue.destination as? QRCodeDetailViewController,
            let paymentRequest = sender as? String {
            qrCodeDetailViewController.viewModel = ReceiveViewModel(paymentRequest: paymentRequest)
        } else if let numericKeyPad = segue.destination as? NumericKeyPadViewController {
            let numberFormatter = InputNumberFormatter(unit: .bit)
            numericKeyPad.handler = { [weak self] input in
                if let output = numberFormatter.validate(input) {
                    self?.createReceiveViewModel?.updateAmount(output)
                    return true
                }
                return false
            }
        }
    }
}

extension ReceiveViewController: UITextFieldDelegate {
    private func animateKeypad(hidden: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [weak self] in
            self?.amountInputView.isHidden = hidden
            }, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateKeypad(hidden: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateKeypad(hidden: true)
    }
}
