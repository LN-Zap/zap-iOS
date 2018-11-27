//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftBTC
import SwiftLnd
import UIKit

final class SendViewController: ModalDetailViewController {
    private let viewModel: SendViewModel
    private let authenticationViewModel: AuthenticationViewModel

    private var didViewAppear = false
    
    init(viewModel: SendViewModel, authenticationViewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        self.authenticationViewModel = authenticationViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentStackView.addArrangedElement(.label(text: viewModel.method.headline, style: Style.Label.headline.with({ $0.textAlignment = .center })))
        contentStackView.addArrangedElement(.separator)
        contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
            .label(text: L10n.Scene.Send.addressHeadline, style: Style.Label.headline),
            .label(text: viewModel.receiver, style: Style.Label.body)
        ]))
        contentStackView.addArrangedElement(.separator)
        
        addAmountInputView()
        
        if let memo = viewModel.memo {
            contentStackView.addArrangedElement(.verticalStackView(content: [
                .label(text: L10n.Scene.Send.memoHeadline, style: Style.Label.headline),
                .label(text: memo, style: Style.Label.body)
            ], spacing: -5))
            contentStackView.addArrangedElement(.separator)
        }
        
        let sendButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: L10n.Scene.Send.sendButton, style: Style.Button.background, completion: { [weak self] _ in
            self?.sendButtonTapped()
        }))) as? CallbackButton
        
        viewModel.sendButtonEnabled
            .observeOn(DispatchQueue.main)
            .observeNext {
                sendButton?.isEnabled = $0
            }
            .dispose(in: reactive.bag)
        
        setHeaderImage(viewModel.method.headerImage)
    }
    
    private func addAmountInputView() {
        let amountInputView = AmountInputView()
        amountInputView.backgroundColor = UIColor.Zap.background
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.delegate = self
        amountInputView.addTarget(self, action: #selector(amountChanged(sender:)), for: .valueChanged)

        contentStackView.addArrangedSubview(amountInputView)
        
        if case .lightning = viewModel.method {
            contentStackView.setCustomSpacing(0, after: amountInputView)
            let stackView = contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
                .label(text: L10n.Scene.Send.maximumFee, style: Style.Label.footnote),
                .customView(LoadingAmountView(loadable: viewModel.lightningFee))
            ]))
            stackView.subviews[0].setContentHuggingPriority(.required, for: .horizontal)
        }
        
        contentStackView.addArrangedElement(.separator)
        
        if let amount = viewModel.amount {
            amountInputView.updateAmount(amount)
            amountInputView.setKeypad(hidden: true, animated: false)
            if case .lightning = viewModel.method {
                amountInputView.isEditable = false
            }
        } else {
            amountInputView.becomeFirstResponder()
        }
    }

    private func authenticate(completion: @escaping (Result<Success>) -> Void) {
        if BiometricAuthentication.type == .none {
            ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { completion($0) }
        } else {
            BiometricAuthentication.authenticate { [authenticationViewModel] result in
                if case .failure(let error) = result,
                    (error as? AuthenticationError) == AuthenticationError.useFallback {
                    ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { completion($0) }
                } else {
                    completion(result)
                }
            }
        }
    }
    
    private func sendButtonTapped() {
        authenticate { [weak self] result in
            switch result {
            case .success:
                self?.send()
            case .failure:
                self?.presentErrorToast(L10n.Scene.Send.authenticationFailed)
            }
        }
    }
    
    private func send() {
        let loadingView = presentLoadingView(text: L10n.Scene.Send.sending)
        viewModel.send { [weak self] result in
            DispatchQueue.main.async {
                loadingView.removeFromSuperview()
                switch result {
                case .success:
                    self?.dismissParent()
                case .failure(let error):
                    self?.presentErrorToast(error.localizedDescription)
                }
            }
        }
    }
    
    override func presentErrorToast(_ message: String) {
        view.superview?.presentErrorToast(message)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didViewAppear = true
    }
    
    @objc private func amountChanged(sender: AmountInputView) {
        viewModel.amount = sender.satoshis
    }
}

extension SendViewController: AmountInputViewDelegate {
    func amountInputViewDidBeginEditing(_ amountInputView: AmountInputView) {
        guard didViewAppear else { return }
        amountInputView.setKeypad(hidden: false, animated: true)
        updateHeight()
    }
    
    func amountInputViewDidEndEditing(_ amountInputView: AmountInputView) {
        guard didViewAppear else { return }
        amountInputView.setKeypad(hidden: true, animated: true)
        updateHeight()
    }
}
