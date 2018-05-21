//
//  Zap
//
//  Created by Otto Suess on 17.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class GradientLoadingButtonView: UIControl {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let gradient = GradientView(frame: CGRect.zero)
        addSubviewSameSize(gradient)
        
        let button = UIButton(type: .system)
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.white, for: .normal)
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
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        activityIndicator.startAnimating()
        
        self.activityIndicator = activityIndicator
    }
    
    private func addSubviewSameSize(_ view: UIView) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
