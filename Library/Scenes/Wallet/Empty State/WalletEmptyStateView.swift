//
//  Library
//
//  Created by 0 on 26.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC

final class WalletEmptyStateView: UIView {
    weak var actionButton: UIButton?

    var action: ((BitcoinURI) -> Void)?
    var viewModel: WalletEmptyStateViewModel?

    init(viewModel: WalletEmptyStateViewModel, action: @escaping (BitcoinURI) -> Void) {
        self.action = action
        self.viewModel = viewModel

        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.Zap.deepSeaBlue
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 24

        let fontSize: CGFloat
        switch UIScreen.main.sizeType {
        case .small:
            fontSize = 25
        case .big:
            fontSize = 40
        }

        let titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = UIColor.Zap.white
        titleLabel.numberOfLines = 0
        titleLabel.setMarkdown(L10n.Scene.Wallet.EmptyState.title, fontSize: fontSize, weight: .light, boldWeight: .medium)

        let messageLabel = UILabel(frame: .zero)
        Style.Label.body.apply(to: messageLabel)
        messageLabel.textColor = UIColor.Zap.gray
        messageLabel.numberOfLines = 0
        messageLabel.text = L10n.Scene.Wallet.EmptyState.message

        let actionButton = UIButton(type: .system)
        Style.Button.background.apply(to: actionButton)
        actionButton.setTitle(L10n.Scene.Wallet.EmptyState.buttonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.actionButton = actionButton

        let imageView = UIImageView(image: Emoji.image(emoji: "🚀"))
        imageView.contentMode = .scaleAspectFit

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel, actionButton])
        stackView.axis = .vertical
        addAutolayoutSubview(stackView)

        stackView.setCustomSpacing(15, after: titleLabel)
        stackView.setCustomSpacing(30, after: messageLabel)

        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: 56),
            // stack view
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 20),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20)
        ])
    }

    @IBAction private func buttonTapped() {
        actionButton?.isEnabled = false
        viewModel?.getAddress { [weak self] bitcoinURI in
            DispatchQueue.main.async {
                self?.actionButton?.isEnabled = true
                self?.action?(bitcoinURI)
            }
        }
    }

    func add(to superview: UIView) {
        superview.addAutolayoutSubview(self)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 20),
            superview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20)
        ])
        superview.bringSubviewToFront(self)
    }
}
