//
//  ZapPos
//
//  Created by Otto Suess on 22.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Library
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var rootCoordinator: RootCoordinator?
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        if let window = window {
            rootCoordinator = RootCoordinator(window: window)
        }
        
        return true
    }
}
