//
//  Library
//
//  Created by Otto Suess on 07.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

indirect enum StackViewElement {
    case label(text: String, style: UIViewStyle<UILabel>)
    case horizontalStackView(content: [StackViewElement])
    case button(title: String, style: UIViewStyle<UIButton>, callback: () -> Void)
    case separator
    
    var height: CGFloat {
        switch self {
        case .separator:
            return 1
        default:
            return 50
        }
    }
    
    var view: UIView {
        let result: UIView
        
        switch self {
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
