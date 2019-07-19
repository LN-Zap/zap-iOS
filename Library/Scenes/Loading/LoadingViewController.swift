//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import SwiftLnd
import UIKit

final class LoadingViewController: UIViewController {
    static func instantiate() -> LoadingViewController {
        return StoryboardScene.Loading.initialScene.instantiate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background
    }
}
