//
//  Library
//
//  Created by Otto Suess on 17.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    var modalPresentationManager: ModalPresentationManager?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        modalPresentationManager = ModalPresentationManager()
        transitioningDelegate = modalPresentationManager
        modalPresentationStyle = .custom
    }

    override func viewDidDisappear(_ animated: Bool) {
        modalPresentationManager = nil
        transitioningDelegate = nil

        super.viewDidDisappear(true)
    }
}
