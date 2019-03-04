//
//  Library
//
//  Created by Otto Suess on 07.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import SwiftBTC
import UIKit

indirect enum StackViewElement {
    case amountLabel(amount: Satoshi, style: UIViewStyle<UILabel>)
    case verticalStackView(content: [StackViewElement], spacing: CGFloat)
    case label(text: String, style: UIViewStyle<UILabel>)
    case horizontalStackView(compressionResistant: HorizontalPriority, content: [StackViewElement])
    case button(title: String, style: UIViewStyle<UIButton>, completion: (UIButton) -> Void)
    case separator
    case customView(UIView)
    case customHeight(CGFloat, element: StackViewElement)

    enum HorizontalPriority {
        case first
        case last
    }

    // swiftlint:disable:next function_body_length
    func view() -> UIView {
        let result: UIView

        switch self {
        case let .amountLabel(amount, style):
            let label = UILabel()

            label.lineBreakMode = .byTruncatingMiddle
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
            style.apply(to: label)
            amount
                .bind(to: label.reactive.text, currency: Settings.shared.primaryCurrency)
                .dispose(in: label.reactive.bag)

            result = label

        case let .verticalStackView(content, spacing):
            let stackView = UIStackView(elements: content)
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.spacing = spacing
            result = stackView

        case let .label(text, style):
            let label = UILabel()
            label.text = text
            label.lineBreakMode = .byTruncatingMiddle
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            style.apply(to: label)
            result = label

        case let .horizontalStackView(compressionResistant, content):
            let stackView = UIStackView(elements: content)
            stackView.axis = .horizontal
            stackView.spacing = 5
            stackView.arrangedSubviews.first?.setContentCompressionResistancePriority(compressionResistant == .first ? .required : .defaultLow, for: .horizontal)
            stackView.arrangedSubviews.first?.setContentHuggingPriority(UILayoutPriority(rawValue: 0), for: .horizontal)
            stackView.arrangedSubviews.last?.setContentCompressionResistancePriority(compressionResistant == .first ? .defaultLow : .required, for: .horizontal)
            stackView.arrangedSubviews.last?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            result = stackView

        case let .button(title, style, completion):
            let button = CallbackButton(title: title, onTap: completion)
            style.apply(to: button.button)

            result = button

        case .separator:
            let view = LineView()
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            result = view

        case let .customView(view):
            result = view
            result.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)

        case let .customHeight(height, element):
            result = element.view()
            result.heightAnchor.constraint(equalToConstant: height).isActive = true
            result.translatesAutoresizingMaskIntoConstraints = false
        }

        return result
    }
}
