//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class SendModalDetailViewController: ModalDetailViewController {
    private let viewModel: SendModalDetailViewModel
    private var didViewAppear = false
    
    init(viewModel: SendModalDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let amountInputView = AmountInputView()
        amountInputView.backgroundColor = UIColor.Zap.seaBlue
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.delegate = self
        
        if let amount = viewModel.amount {
            amountInputView.satoshis = amount
            amountInputView.setKeypad(hidden: true, animated: false)
        } else {
            amountInputView.becomeFirstResponder()
        }
            
        contentStackView.addArrangedElement(.label(text: viewModel.method.headline, style: Style.Label.headline.with({ $0.textAlignment = .center })))
        contentStackView.addArrangedElement(.separator)
        contentStackView.addArrangedElement(.horizontalStackView(content: [
            .label(text: "To:", style: Style.Label.headline),
            .label(text: viewModel.receiver, style: Style.Label.body)
        ]))
        contentStackView.addArrangedElement(.separator)
        contentStackView.addArrangedSubview(amountInputView)
        contentStackView.addArrangedElement(.separator)
        
        if let memo = viewModel.memo {
            contentStackView.addArrangedElement(.verticalStackView(content: [
                .label(text: "Memo:", style: Style.Label.headline),
                .label(text: memo, style: Style.Label.body)
            ], spacing: -5))
            contentStackView.addArrangedElement(.separator)
        }
        
        contentStackView.addArrangedElement(.customHeight(56, element: .button(title: "Send", style: Style.Button.background, callback: { [weak self] button in
            button.isEnabled = false
            self?.viewModel.send(callback: { result in
                button.isEnabled = true
                switch result {
                case .success:
                    self?.dismissParent()
                case .failure(let error):
                    guard let error = error as? LocalizedError,
                        let errorMessage = error.errorDescription
                        else { return }
                    self?.delegate?.presentError(message: errorMessage)
                }
            })
        })))

        setHeaderImage(viewModel.method.headerImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didViewAppear = true
    }
}

extension SendModalDetailViewController: AmountInputViewDelegate {
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
