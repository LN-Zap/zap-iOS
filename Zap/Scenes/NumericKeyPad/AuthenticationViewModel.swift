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
    static let instance = AuthenticationViewModel()

    private let keychain = Keychain(service: "com.jackmallers.zap")
    
    var pin: String? {
        get { return keychain["pin"] }
        set { keychain["pin"] = pin }
    }
    
    let authenticated = Observable(false)
    
    private init() {
        keychain["pin"] = "00000"
    }
}
