//
//  Library
//
//  Created by Otto Suess on 29.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIView {
    public func addAutolayoutSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
    
    func addBackgroundGradient() {
        let backgroundGradientView = GradientView()
        backgroundGradientView.direction = .vertical
        backgroundGradientView.gradient = [UIColor.Zap.seaBlueGradient, UIColor.Zap.seaBlue]
        
        addAutolayoutSubview(backgroundGradientView)
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
    
    func constrainCenter(to view: UIView) {
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func constrainSize(to size: CGSize) {
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: size.width),
            self.heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
}
