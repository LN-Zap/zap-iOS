//
//  Zap
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class RequestViewController: UIViewController {
    @IBOutlet private weak var segmentedControlBackgroundView: UIView!
    @IBOutlet private weak var lightningButton: UIButton!
    @IBOutlet private weak var onChainButton: UIButton!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var placeholderTextView: UITextView!
    @IBOutlet private weak var memoTextView: UITextView!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var amountInputView: UIView!
    @IBOutlet private weak var swapCurrencyButton: UIButton!
    @IBOutlet private weak var downArrowImageView: UIImageView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            self.requestViewModel = RequestViewModel(viewModel: viewModel)
        }
    }
    private var requestViewModel: RequestViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.request.title".localized

        lightningButton.setTitle("Lightning", for: .normal)
        onChainButton.setTitle("On-chain", for: .normal)

        lightningButton.isSelected = true
        
        segmentedControlBackgroundView.backgroundColor = Color.searchBackground
        
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
        
        requestViewModel?.amountString
            .bind(to: amountTextField.reactive.text)
            .dispose(in: reactive.bag)
        
        requestViewModel?.isAmountValid
            .map { $0 ? Color.text : Color.red }
            .bind(to: amountTextField.reactive.textColor)
            .dispose(in: reactive.bag)
        
        memoTextView.reactive.text
            .map { !($0?.isEmpty ?? true) }
            .bind(to: placeholderTextView.reactive.isHidden )
            .dispose(in: reactive.bag)
        
        memoTextView.reactive.text
            .observeNext { [requestViewModel] text in
                requestViewModel?.memo = text
            }
            .dispose(in: reactive.bag)

        setupKeyboardNotifications()
    }
    
    @IBAction private func segmentedControlDidChange(_ sender: UIButton) {
        let isLightningSelected = sender == lightningButton
        lightningButton.isSelected = isLightningSelected
        onChainButton.isSelected = !isLightningSelected
        requestViewModel?.requestMethod = isLightningSelected ? .lightning : .onChain
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func createButtonTapped(_ sender: Any) {
        requestViewModel?.create { [weak self] qrCodeViewModel in
            let viewController = Storyboard.qrCodeDetail.instantiate(viewController: QRCodeDetailViewController.self)
            viewController.viewModel = qrCodeViewModel
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.swapCurrencies()
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.reactive.notification(name: .UIKeyboardWillHide)
            .observeNext { [weak self] _ in
                self?.updateKeyboardConstraint(to: 0)
            }
            .dispose(in: reactive.bag)
        
        NotificationCenter.default.reactive.notification(name: .UIKeyboardWillShow)
            .observeNext { [weak self] notification in
                guard
                    let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
                    else { return }
                self?.updateKeyboardConstraint(to: keyboardFrame.height)
            }
            .dispose(in: reactive.bag)
    }
    
    private func updateKeyboardConstraint(to height: CGFloat) {
        UIView.animate(withDuration: 0.25) { [bottomConstraint, view] in
            bottomConstraint?.constant = height
            view?.layoutIfNeeded()
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let numericKeyPad = segue.destination as? NumericKeyPadViewController else { return }
        let numberFormatter = InputNumberFormatter(unit: .bit)
        
        numericKeyPad.handler = { [weak self] input in
            guard let output = numberFormatter.validate(input) else { return false }
            
            self?.requestViewModel?.updateAmount(output)
            return true
        }
    }
}

extension RequestViewController: UITextFieldDelegate {
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
