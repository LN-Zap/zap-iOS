//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Library
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var rootCoordinator: RootCoordinator?
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString {
            print(documentsDir.replacingOccurrences(of: "file://", with: ""))
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        if let window = window {
            rootCoordinator = RootCoordinator(window: window)
        }
        
        if let url = launchOptions?[.url] as? URL {
            _ = handle(url: url)
            return false
        } else if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            _ = handle(shortcutItem: shortcutItem)
            return false
        }

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return handle(url: url)
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let success = handle(shortcutItem: shortcutItem)
        completionHandler(success)
    }
    
    private func handle(url: URL) -> Bool {
        guard let route = Route(url: url) else { return false }
        rootCoordinator?.handle(route)
        return true
    }
    
    private func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let route = Route(shortcutItem: shortcutItem) else { return false }
        rootCoordinator?.handle(route)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        rootCoordinator?.applicationWillEnterForeground()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        rootCoordinator?.applicationDidEnterBackground()
    }
}
