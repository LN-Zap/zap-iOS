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

    @discardableResult public func constrainEdges(to view: UIView) -> UIView {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        return self
    }

    @discardableResult func constrainCenter(to view: UIView) -> UIView {
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return self
    }

    @discardableResult func constrainSize(to size: CGSize) -> UIView {
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: size.width),
            self.heightAnchor.constraint(equalToConstant: size.height)
        ])
        return self
    }
}
