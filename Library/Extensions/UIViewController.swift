//
//  Zap
//
//  Created by Otto Suess on 27.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

// MARK: - KeyboardAdjustable - listen for keyboard notifications

protocol KeyboardAdjustable {
    func setupKeyboardNotifications(constraint: NSLayoutConstraint)
}

extension KeyboardAdjustable where Self: UIViewController {
    func setupKeyboardNotifications(constraint: NSLayoutConstraint) {
        NotificationCenter.default.reactive.notification(name: UIResponder.keyboardWillHideNotification)
            .observeNext { [weak self] _ in
                self?.updateKeyboardConstraint(to: 0, constraint: constraint)
            }
            .dispose(in: reactive.bag)
        
        NotificationCenter.default.reactive.notification(name: UIResponder.keyboardWillShowNotification)
            .observeNext { [weak self] notification in
                guard
                    let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    else { return }
                self?.updateKeyboardConstraint(to: keyboardFrame.height, constraint: constraint)
            }
            .dispose(in: reactive.bag)
    }
    
    private func updateKeyboardConstraint(to height: CGFloat, constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.25) { [constraint, view] in
            constraint.constant = height
            view?.layoutIfNeeded()
        }
    }
}
