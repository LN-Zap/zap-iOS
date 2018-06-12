//
//  Zap
//
//  Created by Otto Suess on 09.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class DebugButton {
    static let instance = DebugButton()
    private weak var button: UIButton?
    private let buttonTitle = " "
    
    private init() {}
    
    func setup() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let button = UIButton(frame: CGRect(x: window.bounds.width / 2 - 20, y: 30, width: 40, height: 40))
        button.addTarget(self, action: #selector(presentLog), for: .touchUpInside)
        button.setTitle(buttonTitle, for: .normal)
        button.tintColor = .lightGray
        
        let gestureRecognizer = UILongPressGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(hideLogButton(_:)))
        button.addGestureRecognizer(gestureRecognizer)
        
        window.addSubview(button)
        self.button = button
    }
    
    @objc private func hideLogButton(_ sender: Any) {
        guard
            let sender = sender as? UILongPressGestureRecognizer,
            sender.state == .began
            else { return }
        let newTitle = button?.title(for: .normal) == nil ? buttonTitle : nil
        button?.setTitle(newTitle, for: .normal)
    }
    
    @objc private func presentLog(_ sender: Any) {
        UIApplication.topViewController?.present(UIStoryboard.instantiateDebugViewController(), animated: true, completion: nil)
    }
}
