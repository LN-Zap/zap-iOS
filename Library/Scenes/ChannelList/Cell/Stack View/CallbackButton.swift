//
//  Library
//
//  Created by Otto Suess on 07.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class CallbackButton: UIView {
    let onTap: () -> Void
    let button: UIButton
    
    init(title: String, onTap: @escaping () -> Void) {
        self.onTap = onTap
        self.button = UIButton(type: .system)
        super.init(frame: .zero)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.constrainEdges(to: self)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapped(sender: AnyObject) {
        onTap()
    }
}
