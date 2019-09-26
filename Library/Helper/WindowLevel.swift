//
//  Library
//
//  Created by Otto Suess on 30.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum WindowLevel {
    static let backgroundWindow = UIWindow.Level.alert + 10
    static let authentication = UIWindow.Level.normal + 20
    static let modalPin = UIWindow.Level.normal + 10
}
