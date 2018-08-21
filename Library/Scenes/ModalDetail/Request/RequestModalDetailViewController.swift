//
//  Library
//
//  Created by Otto Suess on 21.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

final class RequestModalDetailViewController: ModalDetailViewController {
    private weak var lightningButton: CallbackButton?
    private weak var onChainButton: CallbackButton?
    private weak var titleLabel: UILabel?
    private weak var amountInputView: AmountInputView?
    private weak var bottomSeparator: UIView?
    private weak var nextButton: CallbackButton?
    
    private var viewModel: RequestViewModel
    
    private var currentState = State.methodSelection {
        didSet {
            currentState.configure(viewController: self)
            updateHeight()
        }
    }
    
    private enum State {
        case methodSelection
        case amountInput
        case memoInput
        
        func configure(viewController: RequestModalDetailViewController) {
            switch self {
            case .methodSelection:
                break
            case .amountInput:
                viewController.lightningButton?.isHidden = true
                viewController.onChainButton?.isHidden = true
                viewController.amountInputView?.isHidden = false
                viewController.nextButton?.isHidden = false
                viewController.bottomSeparator?.isHidden = false
            case .memoInput:
                viewController.amountInputView?.setKeypad(hidden: true, animated: true)
                viewController.nextButton?.button.setTitle("Generate Request", for: .normal)
            }
        }
    }
    
    init(viewModel: RequestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel = contentStackView.addArrangedElement(.label(text: "Payment Request", style: Style.Label.headline.with({ $0.textAlignment = .center }))) as? UILabel
        
        setupRequestMethodSelection()
        
        let amountInputView = AmountInputView()
        amountInputView.backgroundColor = UIColor.Zap.seaBlue
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.delegate = self
        amountInputView.addTarget(self, action: #selector(amountChanged(sender:)), for: .valueChanged)
        contentStackView.addArrangedSubview(amountInputView)
        amountInputView.isHidden = true
        self.amountInputView = amountInputView
        
        bottomSeparator = contentStackView.addArrangedElement(.separator)
        bottomSeparator?.isHidden = true
        
        nextButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: "Next", style: Style.Button.background, callback: { [weak self] _ in
            self?.bottomButtonTapped()
        }))) as? CallbackButton
        nextButton?.isHidden = true
    }
    
    private func setupRequestMethodSelection() {
        let lightningImage = UIImage(named: "icon_request_lightning_button", in: .library, compatibleWith: nil)
        let lightningButtonStyle = Style.Button.background.with({
            $0.setImage(lightningImage, for: .normal)
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        })
        lightningButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: "Lightning Transaction", style: lightningButtonStyle, callback: { [weak self] _ in
            self?.presentAmountInput(requestMethod: .lightning)
        }))) as? CallbackButton
        
        contentStackView.addArrangedElement(.separator)
        
        let onChainImage = UIImage(named: "icon_request_on_chain_button", in: .library, compatibleWith: nil)
        let onChainButtonStyle = Style.Button.background.with({
            $0.setImage(onChainImage, for: .normal)
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        })
        onChainButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: "On-Chain Transaction", style: onChainButtonStyle, callback: { [weak self] _ in
            self?.presentAmountInput(requestMethod: .onChain)
        }))) as? CallbackButton
    }
    
    private func headerImage(for requestMethod: RequestViewModel.RequestMethod) -> UIImage {
        let name: String
        switch requestMethod {
        case .lightning:
            name = "icon_header_lightning"
            titleLabel?.text = "Lightning Payment Request"
        case .onChain:
            name = "icon_header_on_chain"
            titleLabel?.text = "On Chain Payment Request"
        }
        guard let image = UIImage(named: name, in: Bundle.library, compatibleWith: nil) else { fatalError("Image not found") }
        return image
    }
    
    private func presentAmountInput(requestMethod: RequestViewModel.RequestMethod) {
        viewModel.requestMethod = requestMethod
        setHeaderImage(headerImage(for: requestMethod))
        currentState = .amountInput
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
        viewModel.create { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let qrCodeDetailViewModel):
                    let viewController = UIStoryboard.instantiateQRCodeDetailViewController(with: qrCodeDetailViewModel)
                    self?.present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
                case .failure(let error):
                    guard let error = error as? LocalizedError else { return }
                    self?.view.superview?.presentErrorToast(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func amountChanged(sender: AmountInputView) {
        viewModel.amount = sender.satoshis
    }
}

extension RequestModalDetailViewController: AmountInputViewDelegate {
    func amountInputViewDidBeginEditing(_ amountInputView: AmountInputView) {
        amountInputView.setKeypad(hidden: false, animated: true)
        updateHeight()
    }
    
    func amountInputViewDidEndEditing(_ amountInputView: AmountInputView) {
        amountInputView.setKeypad(hidden: true, animated: true)
        updateHeight()
    }
}
