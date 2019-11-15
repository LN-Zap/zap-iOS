//
//  Library
//
//  Created by Otto Suess on 21.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

final class RequestViewController: ModalDetailViewController {
    private weak var topSeparator: UIView?
    private weak var lightningButton: CallbackButton?
    private weak var qrCodeButton: CallbackButton?
    private weak var lightningButtonContainer: UIStackView?
    private weak var orSeparator: UIView?
    private weak var onChainButton: CallbackButton?
    private weak var titleLabel: UILabel?
    private weak var amountInputView: AmountInputView?
    private weak var nextButton: CallbackButton?
    private weak var memoSeparator: UIView?
    private weak var memoTextField: UITextField?

    private var viewModel: RequestViewModel
    private var presentQrCode: () -> Void
    
    private var currentState = State.methodSelection {
        didSet {
            guard oldValue != currentState else { return }
            currentState.configure(viewController: self)
            updateHeight()
        }
    }

    private enum State {
        case methodSelection
        case amountInput
        case memoInput

        func configure(viewController: RequestViewController) {
            switch self {
            case .methodSelection:
                break
            case .amountInput:
                viewController.amountInputView?.becomeFirstResponder()
                viewController.amountInputView?.setKeypad(hidden: false, animated: true)
                viewController.topSeparator?.isHidden = false
                viewController.lightningButtonContainer?.isHidden = true
                viewController.orSeparator?.isHidden = true
                viewController.onChainButton?.isHidden = true
                viewController.amountInputView?.isHidden = false
                viewController.nextButton?.isHidden = false
                viewController.memoTextField?.isHidden = true
                viewController.memoSeparator?.isHidden = true
                viewController.nextButton?.button.setTitle(L10n.Scene.Request.nextButtonTitle, for: .normal)
            case .memoInput:
                viewController.amountInputView?.setKeypad(hidden: true, animated: true)
                viewController.memoTextField?.becomeFirstResponder()
                viewController.memoTextField?.isHidden = false
                viewController.memoSeparator?.isHidden = false
                viewController.nextButton?.button.setTitle(L10n.Scene.Request.generateRequestButton, for: .normal)
            }
        }
    }

    init(viewModel: RequestViewModel, presentQrCode: @escaping () -> Void) {
        self.viewModel = viewModel
        self.presentQrCode = presentQrCode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = contentStackView.addArrangedElement(.label(text: L10n.Scene.Request.title, style: Style.Label.headline.with({ $0.textAlignment = .center }))) as? UILabel

        topSeparator = contentStackView.addArrangedElement(.separator)
        topSeparator?.isHidden = true

        setupRequestMethodSelection()

        let amountInputView = AmountInputView()
        amountInputView.backgroundColor = UIColor.Zap.background
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.delegate = self
        amountInputView.addTarget(self, action: #selector(amountChanged(sender:)), for: .valueChanged)
        amountInputView.isHidden = true
        self.amountInputView = amountInputView
        contentStackView.addArrangedSubview(amountInputView)

        memoSeparator = contentStackView.addArrangedElement(.separator)
        memoSeparator?.isHidden = true
        let memoTextField = UITextField()
        Style.textField(color: UIColor.Zap.white).apply(to: memoTextField)
        memoTextField.backgroundColor = UIColor.Zap.background
        memoTextField.attributedPlaceholder = NSAttributedString(
            string: L10n.Generic.Memo.placeholder,
            attributes: [.foregroundColor: UIColor.Zap.gray]
        )
        contentStackView.addArrangedElement(.customHeight(30, element: .customView(memoTextField)))
        memoTextField.isHidden = true
        memoTextField.addTarget(self, action: #selector(updateMemo(sender:)), for: .editingChanged)
        self.memoTextField = memoTextField

        nextButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: L10n.Scene.Request.nextButtonTitle, style: Style.Button.background, completion: { [weak self] _ in
            self?.bottomButtonTapped()
        }))) as? CallbackButton
        nextButton?.isHidden = true
    }

    private func setupRequestMethodSelection() {
        let lightningStackView = UIStackView()
        lightningStackView.spacing = 2
        lightningStackView.axis = .horizontal
        lightningStackView.distribution = .fill
        lightningButtonContainer = lightningStackView
        
        let lightningImage = Asset.iconRequestLightningButton.image
        let lightningButtonStyle = Style.Button.background.with({
            $0.setImage(lightningImage, for: .normal)
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
        })
        lightningButton = lightningStackView.addArrangedElement(.customHeight(56, element: .button(title: L10n.Scene.Request.lightningButton, style: lightningButtonStyle, completion: { [weak self] _ in
            self?.presentAmountInput(requestMethod: .lightning)
        }))) as? CallbackButton
        lightningButton?.accessibilityIdentifier = "Lightning"

        let qrCodeImage = Asset.iconQrCode.image
        let qrCodeButtonStyle = Style.Button.background.with({
            $0.setImage(qrCodeImage, for: .normal)
            $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        })
        qrCodeButton = lightningStackView.addArrangedElement(.customHeight(56, element: .button(title: nil, style: qrCodeButtonStyle, completion: { [weak self] _ in
            self?.presentQrCodeScanner()
        }))) as? CallbackButton
        if let qrCodeButton = qrCodeButton {
            qrCodeButton.addConstraint(qrCodeButton.heightAnchor.constraint(equalTo: qrCodeButton.widthAnchor, multiplier: 1))
        }
        contentStackView.addArrangedElement(.customView(lightningStackView))
        
        addOrSeparator()

        let onChainImage = Asset.iconRequestOnChainButton.image
        let onChainButtonStyle = Style.Button.background.with({
            $0.setImage(onChainImage, for: .normal)
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        })
        onChainButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: L10n.Scene.Request.onChainButton, style: onChainButtonStyle, completion: { [weak self] _ in
            self?.presentAmountInput(requestMethod: .onChain)
        }))) as? CallbackButton
    }
    
    private func addOrSeparator() {
        let horizontalStackView = UIStackView()
        horizontalStackView.spacing = 15
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fill
        let leftSeparator = LineView()
        leftSeparator.backgroundColor = UIColor.Zap.background
        horizontalStackView.addArrangedSubview(leftSeparator)
        horizontalStackView.addArrangedElement(.label(text: L10n.Scene.Request.orSeparatorLabel, style: Style.Label.body))
        let rightSeparator = LineView()
        rightSeparator.backgroundColor = UIColor.Zap.background
        horizontalStackView.addArrangedSubview(rightSeparator)
        contentStackView.addArrangedElement(.customView(horizontalStackView))
        leftSeparator.widthAnchor.constraint(equalTo: rightSeparator.widthAnchor, multiplier: 1, constant: 0).isActive = true
        self.orSeparator = horizontalStackView
    }

    private func updateHeaderImage(for requestMethod: Layer) {
        switch requestMethod {
        case .lightning:
            setHeaderImage(Asset.iconHeaderLightning.image)
            titleLabel?.text = L10n.Scene.Request.lightningHeaderTitle
        case .onChain:
            setHeaderImage(Asset.iconHeaderOnChain.image)
            titleLabel?.text = L10n.Scene.Request.onChainHeaderTitle
        }
    }

    private func presentAmountInput(requestMethod: Layer) {
        viewModel.requestMethod = requestMethod
        updateHeaderImage(for: requestMethod)
        currentState = .amountInput

        if requestMethod == .lightning {
            nextButton?.isEnabled = false
            Settings.shared.primaryCurrency
                .compactMap { [viewModel] in
                    $0.format(satoshis: viewModel.maxRemoteBalance)
                }
                .observeNext { [amountInputView] in
                    amountInputView?.subtitleText = L10n.Scene.Request.Subtitle.lightning($0)
                }
                .dispose(in: reactive.bag)
            amountInputView?.subtitleTextColor = UIColor.Zap.gray
        }
    }
    
    private func presentQrCodeScanner() {
        dismiss(animated: true) { [weak self] in
            self?.presentQrCode()
        }
    }

    private func bottomButtonTapped() {
        switch currentState {
        case .memoInput:
            presentPaymentRequest()
        case .amountInput:
            currentState = .memoInput
        default:
            return
        }
    }

    private func presentPaymentRequest() {
        nextButton?.isEnabled = false
        viewModel.create { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let qrCodeDetailViewModel):
                    let viewController = QRCodeDetailViewController.instantiate(with: qrCodeDetailViewModel)
                    self?.present(UINavigationController(rootViewController: viewController), animated: true) { [weak self] in
                        self?.setHeaderImage(nil)
                    }
                case .failure(let error):
                    Toast.presentError(error.localizedDescription)
                    self?.nextButton?.isEnabled = true
                }
            }
        }
    }

    @objc private func amountChanged(sender: AmountInputView) {
        viewModel.amount = sender.satoshis
        nextButton?.isEnabled = !(viewModel.requestMethod == .lightning && viewModel.amount <= 0)
    }

    @objc private func updateMemo(sender: UITextField) {
        viewModel.memo = sender.text
    }
}

extension RequestViewController: AmountInputViewDelegate {
    func amountInputViewDidBeginEditing(_ amountInputView: AmountInputView) {
        currentState = .amountInput
    }

    func amountInputViewDidEndEditing(_ amountInputView: AmountInputView) {}
}
