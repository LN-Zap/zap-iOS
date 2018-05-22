//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import KeychainAccess

final class AuthenticationViewModel {
    static let shared = AuthenticationViewModel()

    private let keychain = Keychain(service: "com.jackmallers.zap")
    
    var pin: String? {
        get { return keychain["pin"] }
        set { keychain["pin"] = newValue }
    }
    
    var didSetupPin: Bool {
        return keychain["pin"] != nil
    }
    
    let authenticated = Observable(false)
    
    private init() {}
}
