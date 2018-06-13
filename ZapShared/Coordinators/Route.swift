//
//  Zap
//
//  Created by Otto Suess on 02.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

// Parses deep links to routes in the app.
public enum Route {
    case send(String?)
    case request
    
    public init?(url: URL) {
        self = .send(url.absoluteString)
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
