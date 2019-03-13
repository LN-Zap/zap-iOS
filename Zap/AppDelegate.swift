//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Library
import Logger
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var rootCoordinator: RootCoordinator?
    var window: UIWindow?
    var didStartFromBackground = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        didStartFromBackground = false

        guard !Environment.isRunningTests else { return true }

        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString {
            Logger.info(documentsDir.replacingOccurrences(of: "file://", with: ""))
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        if let window = window {
            rootCoordinator = RootCoordinator(window: window)
        }

        rootCoordinator?.start()

        if let url = launchOptions?[.url] as? URL {
            _ = handle(url: url)
            return false
        } else if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            _ = handle(shortcutItem: shortcutItem)
            return false
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
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
        didStartFromBackground = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        rootCoordinator?.applicationDidEnterBackground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard didStartFromBackground else { return }
        rootCoordinator?.applicationDidBecomeActive()
        didStartFromBackground = false
    }
}
