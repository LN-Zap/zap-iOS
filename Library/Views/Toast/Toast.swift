//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

enum ToastStyle: Int {
    case info
    case error
}

final class Toast: UIView {
    @IBOutlet private weak var messageLabel: UILabel?
    
    let style: ToastStyle
    
    private init(style: ToastStyle) {
        self.style = style
        super.init(frame: CGRect.zero)
        setupToast()
    }
    
    convenience init(message: String, style: ToastStyle = .info) {
        self.init(style: style)
        messageLabel?.text = message
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupToast() {
        guard let content = toastView() else { return }
        addSubview(content)
        
        let views = ["content": content]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: views)
        addConstraints(horizontalConstraints)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: views)
        addConstraints(verticalConstraints)
    }
    
    private func toastView() -> UIView? {
        let views = Bundle.shared.loadNibNamed("Toast", owner: self, options: nil)
        guard let content = views?.first as? UIView else { return nil }
        
        if style == .error {
            messageLabel?.textColor = UIColor.zap.tomato
        } else {
            messageLabel?.textColor = UIColor.zap.charcoalGrey
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .white
        
        return content
    }
    
    @IBAction private func dismissToast(_ sender: UITapGestureRecognizer) {
        dismissToast()
    }
    
    func dismissToast() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self?.alpha = 0
            }, completion: { [weak self] _ in
                self?.removeFromSuperview()
        })
    }
}

extension UIViewController {
    func displayError(_ message: String) {
        let toast = Toast(message: message, style: .error)
        presentToast(toast, animated: true, completion: nil)
    }
    
    func presentToast(_ toast: Toast, animated: Bool, completion: ((Bool) -> Void)?) {
        view.addSubview(toast)
        
        setupAutolayoutConstraints(forToast: toast)
        toast.transform = CGAffineTransform(translationX: 0, y: -100)
        
        UIView.animate(withDuration: 0.2, animations: {
            toast.transform = CGAffineTransform.identity
            }, completion: completion)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            toast.dismissToast()
        }
    }
    
    private func setupAutolayoutConstraints(forToast toast: Toast) {
        toast.translatesAutoresizingMaskIntoConstraints = false
        let layoutGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            layoutGuide = view.layoutMarginsGuide
        }
        
        let margin: CGFloat = 10
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: toast, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            toast.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: margin),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: layoutGuide.leadingAnchor, constant: margin),
            toast.trailingAnchor.constraint(greaterThanOrEqualTo: layoutGuide.trailingAnchor, constant: margin)
        ])
    }
}
