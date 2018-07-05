//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class ModalNavigationController: UINavigationController {
    private var modalPresentationManager: ModalPresentationManager?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(rootViewController: UIViewController, size: CGSize? = nil) {
        super.init(rootViewController: rootViewController)
        setup(size: size)
    }
    
    private func setup(size: CGSize? = nil) {
        modalPresentationManager = ModalPresentationManager(size: size)
        transitioningDelegate = modalPresentationManager
        modalPresentationStyle = .custom
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        modalPresentationManager = nil
        transitioningDelegate = nil
        
        super.viewDidDisappear(true)
    }
}
