//
//  Library
//
//  Created by Otto Suess on 07.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

indirect enum StackViewElement {
    case amountLabel(amount: Satoshi, style: UIViewStyle<UILabel>)
    case verticalStackView(content: [StackViewElement], spacing: CGFloat)
    case label(text: String, style: UIViewStyle<UILabel>)
    case horizontalStackView(content: [StackViewElement])
    case button(title: String, style: UIViewStyle<UIButton>, callback: () -> Void)
    case separator
    case custom(view: UIView, height: CGFloat)
    
    var height: CGFloat {
        switch self {
        case .separator:
            return 1
        case let .verticalStackView(content, spacing):
            return content.height + CGFloat(content.count - 1) * spacing
        case .custom(_, let height):
            return height
        default:
            return 22
        }
    }
    
    var view: UIView {
        let result: UIView
        
        switch self {
        case let .amountLabel(amount, style):
            let label = UILabel()

            style.apply(to: label)
            label.textAlignment = .right
            label.lineBreakMode = .byTruncatingMiddle
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
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
            style.apply(to: label)
            label.lineBreakMode = .byTruncatingMiddle
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            result = label
            
        case .horizontalStackView(let content):
            let stackView = UIStackView(elements: content)
            stackView.axis = .horizontal
            stackView.spacing = 5
            result = stackView
            
        case let .button(title, style, callback):
            let button = CallbackButton(title: title, onTap: callback)
            style.apply(to: button.button)
            result = button
            
        case .separator:
            let view = LineView()
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            result = view
            
        case let .custom(view, _):
            result = view
            result.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        }
        
        result.heightAnchor.constraint(equalToConstant: height).isActive = true
        return result
    }
}

extension Array where Element == StackViewElement {
    var height: CGFloat {
        return self.reduce(0) { $0 + $1.height }
    }
}
