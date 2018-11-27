//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class OpenChannelViewController: ModalDetailViewController {
    private let viewModel: OpenChannelViewModel
    private weak var openButton: CallbackButton?
    
    init(viewModel: OpenChannelViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentStackView.addArrangedElement(.label(text: L10n.Scene.OpenChannel.title, style: Style.Label.headline.with({ $0.textAlignment = .center })))
        contentStackView.addArrangedElement(.separator)

        contentStackView.addArrangedElement(.verticalStackView(content: [
            .label(text: L10n.Scene.OpenChannel.channelUriLabel, style: Style.Label.headline),
            .label(text: viewModel.lightningNodeURI.stringValue, style: Style.Label.body)
        ], spacing: -5))
        contentStackView.addArrangedElement(.separator)
        
        let amountInputView = AmountInputView()
        amountInputView.backgroundColor = UIColor.Zap.background
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.addTarget(self, action: #selector(updateAmount(_:)), for: .valueChanged)
        amountInputView.updateAmount(viewModel.amount)
        amountInputView.validRange = viewModel.validRange
        
        contentStackView.addArrangedSubview(amountInputView)
        
        openButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: L10n.Scene.OpenChannel.addButton, style: Style.Button.background, completion: { [weak self] button in
            button.isEnabled = false
            self?.openChannel()
        }))) as? CallbackButton
    }
    
    @objc private func openChannel() {
        viewModel.openChannel { [weak self] result in
            
            DispatchQueue.main.async {
                self?.openButton?.isEnabled = true
                switch result {
                case .success:
                    self?.dismissParent()
                case .failure(let error):
                    self?.view.superview?.presentErrorToast(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func updateAmount(_ sender: AmountInputView) {
        viewModel.amount = sender.satoshis
    }
}
