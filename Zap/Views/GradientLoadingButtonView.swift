//
//  Zap
//
//  Created by Otto Suess on 17.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class GradientLoadingButtonView: UIControl {
    private weak var button: UIButton?
    private weak var activityIndicator: UIActivityIndicatorView?
    
    var isLoading: Bool = false {
        didSet {
            button?.isHidden = isLoading
            if isLoading {
                addActivityIndicator()
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
    
    var title: String? {
        didSet {
            button?.setTitle(title, for: .normal)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            button?.isEnabled = isEnabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let gradient = GradientView(frame: CGRect.zero)
        addSubviewSameSize(gradient)
        
        let button = UIButton(type: .system)
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubviewSameSize(button)
        Style.button.apply(to: button)
        self.button = button
    }
    
    @objc
    private func buttonTapped() {
        isLoading = true
        sendActions(for: .touchUpInside)
    }
    
    private func addActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        self.activityIndicator = activityIndicator
    }
    
    private func addSubviewSameSize(_ view: UIView) {
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
