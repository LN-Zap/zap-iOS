//
//  Library
//
//  Created by 0 on 26.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC

protocol EmptyStateViewModel {
    var title: String { get }
    var message: String { get }
    var buttonTitle: String { get }
    var image: UIImage? { get }

    var buttonEnabled: Observable<Bool> { get }

    func actionButtonTapped()
}

final class EmptyStateView: UIView {
    var viewModel: EmptyStateViewModel

    init(viewModel: EmptyStateViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor.Zap.deepSeaBlue
        layer.cornerRadius = Constants.buttonCornerRadius
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
        titleLabel.setMarkdown(viewModel.title, fontSize: fontSize, weight: .light, boldWeight: .medium)

        let messageLabel = UILabel(frame: .zero)
        Style.Label.body.apply(to: messageLabel)
        messageLabel.textColor = UIColor.Zap.gray
        messageLabel.numberOfLines = 0
        messageLabel.text = viewModel.message

        let actionButton = UIButton(type: .system)
        Style.Button.background.apply(to: actionButton)
        actionButton.setTitle(viewModel.buttonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        let imageView = UIImageView(image: viewModel.image)
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

        viewModel.buttonEnabled
            .bind(to: actionButton.reactive.isEnabled)
            .dispose(in: reactive.bag)
    }

    @IBAction private func buttonTapped() {
        viewModel.actionButtonTapped()
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
