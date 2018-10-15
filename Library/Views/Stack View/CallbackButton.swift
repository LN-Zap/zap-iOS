//
//  Library
//
//  Created by Otto Suess on 07.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class CallbackButton: UIView {
    let onTap: (UIButton) -> Void
    let button: UIButton
    
    var isEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }
    
    init(title: String, onTap: @escaping (UIButton) -> Void) {
        self.onTap = onTap
        self.button = UIButton(type: .system)
        super.init(frame: .zero)
        addAutolayoutSubview(button)
        button.constrainEdges(to: self)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapped(sender: AnyObject) {
        onTap(button)
    }
}
