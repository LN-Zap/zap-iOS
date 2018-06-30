//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController, ContainerViewController {
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DebugButton.instance.setup()
    }
}
