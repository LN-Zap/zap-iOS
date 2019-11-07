//
//  Library
//
//  Created by Otto Suess on 29.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

/**
 Displayed when the app is sent to the background
 */
final class BackgoundViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    static func instantiate() -> BackgoundViewController {
        let viewController = StoryboardScene.Background.backgoundViewController.instantiate()
        viewController.modalPresentationStyle = .fullScreen
        return viewController
    }
}
