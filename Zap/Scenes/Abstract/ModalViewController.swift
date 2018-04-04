//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    private let modalPresentationManager = ModalPresentationManager()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = modalPresentationManager
    }
}

class ModalNavigationController: UINavigationController {
    private let modalPresentationManager = ModalPresentationManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = modalPresentationManager
    }
}
