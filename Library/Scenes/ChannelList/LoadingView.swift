//
//  Library
//
//  Created by Otto Suess on 09.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class LoadingView: UIView {
    private let size = CGSize(width: 100, height: 100)
    
    init(text: String) {
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 15
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel(frame: CGRect.zero)
        Style.Label.custom(color: .white).apply(to: label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        addSubview(label)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
}

extension UIViewController {
    func presentLoadingView(text: String) -> LoadingView {        
        let loadingView = LoadingView(text: text)
        view.addSubview(loadingView)
        loadingView.constrainCenter(to: view)
        return loadingView
    }
}
