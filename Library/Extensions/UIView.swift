//
//  Library
//
//  Created by Otto Suess on 29.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIView {
    func addBackgroundGradient() {
        let backgroundGradientView = GradientView()
        backgroundGradientView.direction = .vertical
        backgroundGradientView.gradient = [UIColor.zap.backgroundGradientTop, UIColor.zap.backgroundGradientBottom]
        backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundGradientView)
        sendSubview(toBack: backgroundGradientView)
        
        NSLayoutConstraint.activate([
            backgroundGradientView.topAnchor.constraint(equalTo: topAnchor),
            backgroundGradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGradientView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func constrainEdges(to view: UIView) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
