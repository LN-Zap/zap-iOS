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
    @IBOutlet private weak var placeholderTextView: UITextView!
    @IBOutlet private weak var memoTextView: UITextView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var amountInputView: AmountInputView!
    @IBOutlet private weak var gradientLoadingButtonView: GradientLoadingButtonView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            self.requestViewModel = RequestViewModel(viewModel: viewModel)
        }
    }
    private var requestViewModel: RequestViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextStyle = .dark
        
        title = "scene.request.title".localized

        lightningButton.setTitle("Lightning", for: .normal)
        onChainButton.setTitle("On-chain", for: .normal)

        lightningButton.isSelected = true
        
        segmentedControlBackgroundView.backgroundColor = UIColor.zap.searchBackground
        
        gradientLoadingButtonView.title = "Generate Request"
        
        placeholderTextView.text = "Memo (optional)"
        placeholderTextView.font = UIFont.zap.light.withSize(14)
        placeholderTextView.textColor = UIColor.zap.disabled
        memoTextView.font = UIFont.zap.light.withSize(14)
        memoTextView.textColor = UIColor.zap.text
        
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
        
        amountInputView.validRange = (0...Lnd.Constants.maxPaymentAllowed)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gradientLoadingButtonView.isLoading = false
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
    
    @IBAction private func updateAmount(_ sender: Any) {
        requestViewModel?.amount = amountInputView.satoshis
    }
    
    @IBAction private func createButtonTapped(_ sender: Any) {
        requestViewModel?.create { [weak self] in
            let viewController = UIStoryboard.instantiateQRCodeDetailViewController(with: $0)
            DispatchQueue.main.async {
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
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
}
