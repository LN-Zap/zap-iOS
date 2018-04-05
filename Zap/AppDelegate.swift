//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? {
        didSet {
            window?.tintColor = Color.tint
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {        
        UIApplication.shared.isIdleTimerDisabled = true
        Appearance.setup()
        
        Scheduler.schedule(interval: 120, job: ExchangeUpdaterJob()) // TODO: move this somewhere else?
        
        Lnd.instance.startLnd()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Lnd.instance.stopLnd()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        print("OPEN URL: \(url)") // TODO
        return true
    }
}
