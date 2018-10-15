//
//  ZapMessages
//
//  Created by Otto Suess on 14.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Library
import Lightning
import Messages
import SwiftLnd
import UIKit

protocol MessagesRequestViewControllerDelegate: class {
    func requestPresentationStyle(_ presentationStyle: MSMessagesAppPresentationStyle)
    func insertMessage(text: String, invoice: String)
}

class MessagesRequestViewController: UIViewController {
    @IBOutlet private weak var segmentedControlBackgroundView: UIView!
    @IBOutlet private weak var segmentedControlStackView: UIStackView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var placeholderTextView: UITextView!
    @IBOutlet private weak var memoTextView: UITextView!
    @IBOutlet private weak var memoContainerView: UIView!
    
    private weak var lightningButton: SegmentButton?
    private weak var onChainButton: SegmentButton?
    private weak var amountInputView: AmountInputView?
    
    weak var delegate: MessagesRequestViewControllerDelegate?
    
    var requestViewModel: RequestViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestViewModel = RequestViewModelFactory.create()
        
        setupSegmentedControl()
        setupAmountView()
        setupMemo()
        setupGradientLoadingButtonView()
        
        lightningButton?.isSelected = true
        memoContainerView.isHidden = true
    }
    
    private func setupGradientLoadingButtonView() {
        let gradientLoadingButtonView = GradientLoadingButtonView(frame: CGRect.zero)
        gradientLoadingButtonView.addTarget(self, action: #selector(generateRequest), for: .touchUpInside)
        gradientLoadingButtonView.title = "Generate Request"
        gradientLoadingButtonView.translatesAutoresizingMaskIntoConstraints = false
        gradientLoadingButtonView.heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        stackView.addArrangedSubview(gradientLoadingButtonView)
    }
    
    private func setupAmountView() {
        let amountInputView = AmountInputView(frame: CGRect.zero)
        self.amountInputView = amountInputView
        amountInputView.translatesAutoresizingMaskIntoConstraints = false
        amountInputView.context = .messages
        amountInputView.delegate = self
        amountInputView.validRange = (0...LndConstants.maxPaymentAllowed)
        amountInputView.addTarget(self, action: #selector(updateAmount), for: .valueChanged)
        stackView.insertArrangedSubview(amountInputView, at: 1)
    }
    
    private func setupMemo() {
        let memoLineView = LineView(frame: CGRect.zero)
        memoLineView.backgroundColor = .clear
        memoContainerView.addAutolayoutSubview(memoLineView)
        
        NSLayoutConstraint.activate([
            memoLineView.heightAnchor.constraint(equalToConstant: 1),
            memoLineView.leadingAnchor.constraint(equalTo: memoContainerView.leadingAnchor),
            memoLineView.trailingAnchor.constraint(equalTo: memoContainerView.trailingAnchor),
            memoLineView.bottomAnchor.constraint(equalTo: memoContainerView.topAnchor, constant: 1)
        ])
        
        placeholderTextView.text = "generic.memo.placeholder".localized
        placeholderTextView.font = UIFont.Zap.light.withSize(14)
        placeholderTextView.textColor = UIColor.Zap.gray
        memoTextView.font = UIFont.Zap.light.withSize(14)
        memoTextView.textColor = UIColor.Zap.black
        memoTextView.returnKeyType = .done
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
    }
    
    private func setupSegmentedControl() {
        let lightningButton = SegmentButton(frame: CGRect.zero)
        self.lightningButton = lightningButton
        lightningButton.translatesAutoresizingMaskIntoConstraints = false
        lightningButton.setTitle("Lightning", for: .normal)
        lightningButton.alignment = .horizontal
        lightningButton.setImage(UIImage(named: "icon-request-lightning", in: Bundle.library, compatibleWith: nil), for: .normal)
        lightningButton.addTarget(self, action: #selector(segmentedControlDidChange), for: .touchUpInside)
        segmentedControlStackView.addArrangedSubview(lightningButton)
        
        let onChainButton = SegmentButton(frame: CGRect.zero)
        self.onChainButton = onChainButton
        onChainButton.translatesAutoresizingMaskIntoConstraints = false
        onChainButton.setTitle("On-chain", for: .normal)
        onChainButton.alignment = .horizontal
        onChainButton.setImage(UIImage(named: "icon-request-on-chain", in: Bundle.library, compatibleWith: nil), for: .normal)
        onChainButton.addTarget(self, action: #selector(segmentedControlDidChange), for: .touchUpInside)
        segmentedControlStackView.addArrangedSubview(onChainButton)
        
        segmentedControlBackgroundView.backgroundColor = UIColor.Zap.white
        
        let segmentedControlLineView = LineView(frame: CGRect.zero)
        segmentedControlLineView.backgroundColor = .white
        segmentedControlBackgroundView.addAutolayoutSubview(segmentedControlLineView)
        
        NSLayoutConstraint.activate([
            segmentedControlLineView.heightAnchor.constraint(equalToConstant: 1),
            segmentedControlLineView.leadingAnchor.constraint(equalTo: segmentedControlBackgroundView.leadingAnchor),
            segmentedControlLineView.trailingAnchor.constraint(equalTo: segmentedControlBackgroundView.trailingAnchor),
            segmentedControlLineView.bottomAnchor.constraint(equalTo: segmentedControlBackgroundView.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func generateRequest(_ sender: GradientLoadingButtonView) {
        guard let requestViewModel = requestViewModel else { return }
        
        requestViewModel.create { [weak self] result in
            DispatchQueue.main.async {
                guard let address = result.value?.paymentURI.uriString else { return }
                var text = ""
                
                if requestViewModel.amount > 0,
                    let amountString = Settings.shared.primaryCurrency.value.format(satoshis: requestViewModel.amount) {
                    text = amountString + " "
                }
                
                if let memo = requestViewModel.trimmedMemo,
                    !memo.isEmpty {
                    text += "for " + memo
                }
                
                self?.delegate?.insertMessage(text: text, invoice: address)
                sender.isLoading = false
            }
        }
    }
    
    @objc private func segmentedControlDidChange(_ sender: UIButton) {
        let isLightningSelected = sender == lightningButton
        lightningButton?.isSelected = isLightningSelected
        onChainButton?.isSelected = !isLightningSelected
        requestViewModel?.requestMethod = isLightningSelected ? .lightning : .onChain
    }
    
    @objc private func updateAmount(_ sender: Any) {
        guard let satoshis = amountInputView?.satoshis else { return }
        requestViewModel?.amount = satoshis
    }
    
    func updatePresentationStyle(to presentationStyle: MSMessagesAppPresentationStyle) {
        let isCompact = presentationStyle == .compact
        amountInputView?.setKeypad(hidden: isCompact, animated: true)
        memoContainerView.isHidden = isCompact
    }
}

extension MessagesRequestViewController: AmountInputViewDelegate {
    func amountInputViewDidBeginEditing(_ amountInputView: AmountInputView) {
        delegate?.requestPresentationStyle(.expanded)
    }
    
    func amountInputViewDidEndEditing(_ amountInputView: AmountInputView) {
        // nothing
    }
}

extension MessagesRequestViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        amountInputView?.setKeypad(hidden: true, animated: true)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard var text = textView.text else { return }
        if text.last == "\n" {
            text.removeLast()
            textView.text = text
            textView.resignFirstResponder()
        }
    }
}
