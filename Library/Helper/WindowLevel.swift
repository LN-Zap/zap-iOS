//
//  Library
//
//  Created by Otto Suess on 30.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

enum WindowLevel {
    static let backgroundWindow = UIWindowLevelAlert + 10
    static let fakeBiometricAuthentication = UIWindowLevelNormal + 30
    static let authentication = UIWindowLevelNormal + 20
    static let modalPin = UIWindowLevelNormal + 10
}
