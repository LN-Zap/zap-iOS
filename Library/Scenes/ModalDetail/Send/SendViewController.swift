//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

final class SendViewController: ModalDetailViewController {
    private let viewModel: SendViewModel
    private let authenticationViewModel: AuthenticationViewModel

    private var didViewAppear = false
    private weak var sendButton: CallbackButton?
    
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
        
        let amountInputView = AmountInputView()
        amountInputView.backgroundColor = UIColor.Zap.background
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.delegate = self
        amountInputView.addTarget(self, action: #selector(amountChanged(sender:)), for: .valueChanged)
        
        contentStackView.addArrangedElement(.label(text: viewModel.method.headline, style: Style.Label.headline.with({ $0.textAlignment = .center })))
        contentStackView.addArrangedElement(.separator)
        contentStackView.addArrangedElement(.horizontalStackView(content: [
            .label(text: "scene.send.address_headline".localized, style: Style.Label.headline),
            .label(text: viewModel.receiver, style: Style.Label.body)
        ]))
        contentStackView.addArrangedElement(.separator)
        contentStackView.addArrangedSubview(amountInputView)
        contentStackView.addArrangedElement(.separator)
        
        if let memo = viewModel.memo {
            contentStackView.addArrangedElement(.verticalStackView(content: [
                .label(text: "scene.send.memo_headline".localized, style: Style.Label.headline),
                .label(text: memo, style: Style.Label.body)
            ], spacing: -5))
            contentStackView.addArrangedElement(.separator)
        }
        
        sendButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: "scene.send.send_button".localized, style: Style.Button.background, completion: { [weak self] _ in
            self?.sendButtonTapped()
        }))) as? CallbackButton
        
        if let amount = viewModel.amount {
            amountInputView.satoshis = amount
            amountInputView.setKeypad(hidden: true, animated: false)
            if case .lightning = viewModel.method {
                amountInputView.isEditable = false
            }
        } else {
            amountInputView.becomeFirstResponder()
            sendButton?.isEnabled = false
        }

        setHeaderImage(viewModel.method.headerImage)
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
        sendButton?.isEnabled = false
        authenticate { [weak self] result in
            switch result {
            case .success:
                self?.send()
            case .failure:
                self?.sendButton?.isEnabled = true
                self?.presentErrorToast("scene.send.authentication_failed".localized)
            }
        }
    }
    
    private func send() {
        let loadingView = presentLoadingView(text: "scene.send.sending".localized)
        viewModel.send { [weak self] result in
            DispatchQueue.main.async {
                loadingView.removeFromSuperview()
                switch result {
                case .success:
                    self?.dismissParent()
                case .failure(let error):
                    self?.sendButton?.isEnabled = true
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
        sendButton?.isEnabled = sender.satoshis > 0
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
