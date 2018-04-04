//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class LargeTitleNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.prefersLargeTitles = true
    }
}
