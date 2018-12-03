//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

private enum ToastStyle: Int {
    case info
    case error
    case success
}

private final class ToastView: UIView {
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
        addAutolayoutSubview(content)
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func toastView() -> UIView? {
        let views = Bundle.library.loadNibNamed("Toast", owner: self, options: nil)
        guard let content = views?.first as? UIView else { return nil }
        
        switch style {
        case .info:
            backgroundColor = .white
            messageLabel?.textColor = UIColor.Zap.deepSeaBlue
        case .error:
            backgroundColor = UIColor.Zap.superRed
            messageLabel?.textColor = .white
        case .success:
            backgroundColor = UIColor.Zap.superGreen
            messageLabel?.textColor = .white
        }
        
        content.backgroundColor = backgroundColor
        content.translatesAutoresizingMaskIntoConstraints = false
        
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

private extension UIView {
    func presentErrorToast(_ message: String) {
        DispatchQueue.main.async {
            let toast = ToastView(message: message, style: .error)
            self.presentToast(toast, animated: true, completion: nil)
        }
    }
    
    func presentSuccessToast(_ message: String) {
        DispatchQueue.main.async {
            let toast = ToastView(message: message, style: .success)
            self.presentToast(toast, animated: true, completion: nil)
        }
    }
    
    func presentToast(_ toast: ToastView, animated: Bool, completion: ((Bool) -> Void)?) {
        addAutolayoutSubview(toast)
        
        setupAutolayoutConstraints(forToast: toast)
        
        toast.alpha = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            toast.alpha = 1
        }, completion: completion)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            toast.dismissToast()
        }
    }
    
    private func setupAutolayoutConstraints(forToast toast: ToastView) {
        toast.translatesAutoresizingMaskIntoConstraints = false
        let layoutGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            layoutGuide = safeAreaLayoutGuide
        } else {
            layoutGuide = layoutMarginsGuide
        }
        
        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: topAnchor),
            toast.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            toast.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        ])
    }
}

enum Toast {
    static func presentError(_ message: String) {
        UIApplication.shared.windows.first?.presentErrorToast(message)
    }
    
    static func presentSuccess(_ message: String) {
        UIApplication.shared.windows.first?.presentSuccessToast(message)
    }
}
