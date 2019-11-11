//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import Logger
import SwiftBTC
import SwiftLnd
import UIKit

extension Formatter {
    static let asPercentage: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 3
        formatter.multiplier = 1
        return formatter
    }()
}

extension Int {
    var formattedAsPercentage: String {
        return Formatter.asPercentage.string(for: self) ?? ""
    }
}

extension Decimal {
    var formattedAsPercentage: String {
        return Formatter.asPercentage.string(for: self) ?? ""
    }
}

final class SendViewController: ModalDetailViewController {
    private let viewModel: SendViewModel
    private let authenticationViewModel: AuthenticationViewModel

    private var didViewAppear = false

    private weak var amountInputView: AmountInputView?
    private weak var onChainFeeView: OnChainFeeView?

    // loading views
    private weak var loadingView: LoadingAnimationView?
    private weak var loadingViewCenterYConstraint: NSLayoutConstraint?

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

        if let memo = viewModel.memo, !memo.isEmpty {
            contentStackView.addArrangedElement(.verticalStackView(content: [
                .label(text: L10n.Scene.Send.memoHeadline, style: Style.Label.headline),
                .label(text: memo, style: Style.Label.body)
            ], spacing: -5))
            contentStackView.addArrangedElement(.separator)
        }

        let sendButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: L10n.Scene.Send.sendButton, style: Style.Button.background, completion: { [weak self] _ in
            self?.sendButtonTapped()
        }))) as? CallbackButton

        viewModel.isSendButtonEnabled
            .observeOn(DispatchQueue.main)
            .observeNext { sendButton?.isEnabled = $0 }
            .dispose(in: reactive.bag)

        viewModel.isInputViewEnabled
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                self?.amountInputView?.isEnabled = $0
            }
            .dispose(in: reactive.bag)

        setHeaderImage(viewModel.method.headerImage)

        viewModel.subtitleText
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                self?.amountInputView?.subtitleText = $0
            }
            .dispose(in: reactive.bag)

        viewModel.isSubtitleTextWarning
            .map { $0 ? UIColor.Zap.superRed : UIColor.Zap.gray }
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                self?.amountInputView?.subtitleTextColor = $0
            }
            .dispose(in: reactive.bag)
        
        viewModel.sendStatus.observeNext { [weak self] feeLimitPercent in
            self?.triggerSend(feeLimitPercent: feeLimitPercent)
        }.dispose(in: reactive.bag)
        
        viewModel.sendStatus.observeFailed { [weak self] error in
            switch error {
            case .feeGreaterThanPayment(let feeInfo):
                self?.showFeeLimitAlert(feePercentage: feeInfo.feePercentage, userFeeLimitPercent: feeInfo.userFeeLimitPercentage, sendFeeLimitPercent: feeInfo.sendFeeLimitPercentage)
            case .feePercentageGreaterThanUserLimit(let feeInfo):
                self?.showFeeLimitAlert(feePercentage: feeInfo.feePercentage, userFeeLimitPercent: feeInfo.userFeeLimitPercentage, sendFeeLimitPercent: feeInfo.sendFeeLimitPercentage)
            }
        }.dispose(in: reactive.bag)
    }

    private func addAmountInputView() {
        let amountInputView = AmountInputView()
        amountInputView.backgroundColor = UIColor.Zap.background
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.delegate = self
        amountInputView.addTarget(self, action: #selector(amountChanged(sender:)), for: .valueChanged)

        contentStackView.addArrangedSubview(amountInputView)

        addFeeSelection()

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

        self.amountInputView = amountInputView
    }

    private func addFeeSelection() {
        contentStackView.addArrangedElement(.separator)

        switch viewModel.method {
        case .onChain:
            addOnChainFeeSelection()
        case .lightning:
            addLightningFeeSelection()
        }
    }

    private func addOnChainFeeSelection() {
        let onChainFeeView = OnChainFeeView(loadable: viewModel.fee)
        onChainFeeView.delegate = self
        contentStackView.addArrangedElement(.customView(onChainFeeView))
        self.onChainFeeView = onChainFeeView
    }

    private func addLightningFeeSelection() {
        let content: [StackViewElement] = [
            .label(text: L10n.Scene.Send.maximumFee, style: Style.Label.footnote),
            .customView(LoadingAmountView(loadable: viewModel.fee)),
            .customView(UIView()) // add an empty view to keep the LoadingAmountView to the left
        ]

        let horizontalStackView = contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: content))
        horizontalStackView.subviews[0].setContentHuggingPriority(.required, for: .horizontal)
    }

    private func authenticate(completion: @escaping (Result<Success, AuthenticationError>) -> Void) {
        if BiometricAuthentication.type == .none {
            ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { completion($0) }
        } else {
            BiometricAuthentication.authenticate(viewController: self) { [authenticationViewModel] result in
                if case .failure(let error) = result,
                    error == AuthenticationError.useFallback {
                    ModalPinViewController.authenticate(authenticationViewModel: authenticationViewModel) { completion($0) }
                } else {
                    completion(result)
                }
            }
        }
    }

    private func sendButtonTapped() {
        viewModel.determineSendStatus()
    }
    
    private func showFeeLimitAlert(feePercentage: Decimal, userFeeLimitPercent: Int, sendFeeLimitPercent: Int?) {
        let message: String
        switch viewModel.method {
        case .onChain:
            message = """
            \(L10n.Scene.Send.feeExceedsUserLimit(feePercentage.formattedAsPercentage, userFeeLimitPercent.formattedAsPercentage))
            
            \(L10n.Scene.Send.OnChain.paymentConfirmation)
            """
        case .lightning:
            message = """
            \(L10n.Scene.Send.feeExceedsUserLimit(feePercentage.formattedAsPercentage, userFeeLimitPercent.formattedAsPercentage))
            
            \(L10n.Scene.Send.Lightning.paymentConfirmation)
            """
        }
        let controller = UIAlertController.feeLimitAlertController(message: message) { [weak self] in
            self?.triggerSend(feeLimitPercent: sendFeeLimitPercent)
        }
        self.present(controller, animated: true)
    }

    private func presentLoading() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.contentStackView.alpha = 0
            self?.headerIconImageView.alpha = 0
        }, completion: { [weak self] _ in
            self?.contentStackView.isHidden = true
            self?.headerIconImageView.isHidden = true
        })

        let loadingImage: ImageAsset
        switch viewModel.method {
        case .lightning:
            loadingImage = Asset.loadingLightning
        case .onChain:
            loadingImage = Asset.loadingOnChain
        }

        let size = CGSize(width: 50, height: 50)
        let loadingView = LoadingAnimationView(frame: CGRect(origin: .zero, size: size), loadingImage: loadingImage)
        loadingView.startAnimating()
        view.addAutolayoutSubview(loadingView)

        loadingView.constrainSize(to: size)

        let centerYConstraint = loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        self.loadingViewCenterYConstraint = centerYConstraint

        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYConstraint
        ])

        self.loadingView = loadingView
    }

    private func recoverFromLoadingState() {
        contentStackView.isHidden = false
        headerIconImageView.isHidden = false

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.contentStackView.alpha = 1
            self?.headerIconImageView.alpha = 1
        }

        loadingView?.removeFromSuperview()
    }

    private func presentSuccess() {
        loadingView?.stopAnimation(afterCompletion: afterSuccessAnimationCompleted)
    }

    private func afterSuccessAnimationCompleted() {
        guard let loadingView = loadingView else { return }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        let successLabel = UILabel(frame: .zero)
        Style.Label.body.apply(to: successLabel)
        successLabel.text = L10n.Scene.Send.successLabel
        successLabel.numberOfLines = 0
        successLabel.textColor = UIColor.Zap.superGreen
        successLabel.alpha = 0
        successLabel.textAlignment = .center
        view.addAutolayoutSubview(successLabel)

        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: successLabel.centerXAnchor),
            loadingView.bottomAnchor.constraint(equalTo: successLabel.topAnchor, constant: -15),
            successLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 15)
        ])

        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) { [weak self] in
            successLabel.alpha = 1
            self?.loadingViewCenterYConstraint?.constant = -40
            self?.view.layoutIfNeeded()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.6) { [weak self] in
            self?.dismissParent()
        }
    }
    
    private func triggerSend(feeLimitPercent: Int?) {
        authenticate { [weak self] result in
            switch result {
            case .success:
                let sendStartTime = Date()
                
                self?.presentLoading()
                self?.viewModel.send(feeLimitPercent: feeLimitPercent) { result in
                    let minimumLoadingTime: TimeInterval = 1
                    let sendingTime = Date().timeIntervalSince(sendStartTime)
                    let delay = max(0, minimumLoadingTime - sendingTime)

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                        switch result {
                        case .success:

                            self?.presentSuccess()
                        case .failure(let error):
                            UINotificationFeedbackGenerator().notificationOccurred(.error)

                            Toast.presentError(error.localizedDescription)
                            self?.amountInputView?.isEnabled = true
                            self?.recoverFromLoadingState()
                        }
                    }
                }
            case .failure:
                Toast.presentError(L10n.Scene.Send.authenticationFailed)
            }
        }
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
        onChainFeeView?.expanded = false
        updateHeight()
    }

    func amountInputViewDidEndEditing(_ amountInputView: AmountInputView) {
        guard didViewAppear else { return }
        amountInputView.setKeypad(hidden: true, animated: true)
        updateHeight()
    }
}

extension SendViewController: OnChainFeeViewDelegate {
    func confirmationTargetChanged(to confirmationTarget: Int) {
        viewModel.confirmationTarget = confirmationTarget
    }

    func didChangeSize(expanded: Bool) {
        if expanded {
            amountInputView?.setKeypad(hidden: true, animated: true)
            amountInputView?.resignFirstResponder()
        }

        updateHeight()
    }
}
