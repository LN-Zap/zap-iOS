//
//  Zap
//
//  Created by Otto Suess on 10.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateRequestViewController(with requestViewModel: RequestViewModel) -> UINavigationController {
        let navigationController = Storyboard.request.initial(viewController: UINavigationController.self)
        if let viewController = navigationController.topViewController as? RequestViewController {
            viewController.requestViewModel = requestViewModel
        }
        return navigationController
    }
}

final class RequestViewController: UIViewController, KeyboardAdjustable {
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
    
    fileprivate var requestViewModel: RequestViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextStyle = .dark
        
        title = "scene.request.title".localized

        lightningButton.setTitle("scene.request.lightning_button".localized, for: .normal)
        onChainButton.setTitle("scene.request.on_chain_button".localized, for: .normal)

        lightningButton.isSelected = true
        
        segmentedControlBackgroundView.backgroundColor = UIColor.Zap.white
        
        gradientLoadingButtonView.title = "scene.request.generate_request_button".localized
        
        placeholderTextView.text = "scene.request.memo_placeholder".localized
        placeholderTextView.font = UIFont.Zap.light.withSize(14)
        placeholderTextView.textColor = UIColor.Zap.lightGrey
        memoTextView.font = UIFont.Zap.light.withSize(14)
        memoTextView.textColor = UIColor.Zap.black
        memoTextView.delegate = self
        
        memoTextView.reactive.text
            .map { !($0?.isEmpty ?? true) }
            .bind(to: placeholderTextView.reactive.isHidden )
            .dispose(in: reactive.bag)
        
        memoTextView.reactive.text
            .observeNext { [requestViewModel] text in
                requestViewModel?.memo = text
            }
            .dispose(in: reactive.bag)

        setupKeyboardNotifications(constraint: bottomConstraint)
        
        amountInputView.validRange = (0...LndConstants.maxPaymentAllowed)
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
        requestViewModel?.create { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let qrCodeDetailViewModel):
                    let viewController = UIStoryboard.instantiateQRCodeDetailViewController(with: qrCodeDetailViewModel)
                    self?.navigationController?.pushViewController(viewController, animated: true)
                case .failure(let error):
                    self?.presentErrorToast(error.localizedDescription)
                    self?.gradientLoadingButtonView.isLoading = false
                }
            }
        }
    }
    
    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.shared.swapCurrencies()
    }
}

extension RequestViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        amountInputView?.animateKeypad(hidden: true)
        return true
    }
}
