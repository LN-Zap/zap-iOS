//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

protocol Routing {
    func handle(_ route: Route)
}

// Parses deep links to routes in the app.
public enum Route {
    case send(String?)
    case request
    
    public init?(url: URL) {
        let urlString = url.absoluteString.replacingOccurrences(of: "//", with: "")
        self = .send(urlString)
    }
    
    public init?(shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case "com.jackmallers.zap.send":
            self = .send(nil)
        case "com.jackmallers.zap.request":
            self = .request
        default:
            return nil
        }
    }
}
