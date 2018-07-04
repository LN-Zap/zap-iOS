//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class ModalViewController: UIViewController {
    private let modalPresentationManager = ModalPresentationManager()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = modalPresentationManager
    }
}

final class ModalNavigationController: UINavigationController {
    private let modalPresentationManager = ModalPresentationManager()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup()
    }
    
    private func setup() {
        modalPresentationStyle = .custom
        transitioningDelegate = modalPresentationManager
    }
}
