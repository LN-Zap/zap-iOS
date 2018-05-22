//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var blurEffectView: UIVisualEffectView?

    var window: UIWindow? {
        didSet {
            window?.tintColor = Color.tint
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {        
        UIApplication.shared.isIdleTimerDisabled = true
        Appearance.setup()
        
        Scheduler.schedule(interval: 60 * 10, job: ExchangeUpdaterJob()) // TODO: move this somewhere else?
        
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString {
            print("💾", documentsDir.replacingOccurrences(of: "file://", with: ""))
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        print("OPEN URL: \(url)") // TODO
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        guard let window = window else { return }
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window.frame
        window.addSubview(blurEffectView)
        
        self.blurEffectView = blurEffectView
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        blurEffectView?.removeFromSuperview()
    }
}
