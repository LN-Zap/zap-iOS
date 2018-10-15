//
//  Zap
//
//  Created by Otto Suess on 17.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Library
import UIKit

public final class GradientLoadingButtonView: UIControl {
    private weak var button: UIButton?
    private weak var activityIndicator: UIActivityIndicatorView?
    
    public var isLoading: Bool = false {
        didSet {
            button?.isHidden = isLoading
            if isLoading {
                addActivityIndicator()
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
    
    public var title: String? {
        didSet {
            UIView.performWithoutAnimation {
                button?.setTitle(title, for: .normal)
                button?.layoutIfNeeded()
            }
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            button?.isEnabled = isEnabled
        }
    }
    
    override public required init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let gradient = GradientView(frame: CGRect.zero)
        addSameSizeSubview(gradient)
        
        let button = UIButton(type: .system)

        Style.Button.custom(color: .white).apply(to: button)

        button.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSameSizeSubview(button)
        self.button = button
    }
    
    @objc private func buttonTapped() {
        isLoading = true
        sendActions(for: .touchUpInside)
    }
    
    private func addActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        addAutolayoutSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        self.activityIndicator = activityIndicator
    }
    
    private func addSameSizeSubview(_ view: UIView) {
        addAutolayoutSubview(view)
        self.constrainEdges(to: view)
    }
}
