//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

final class WalletService {
    static private let PASSWORD = "12345678"
    
    private(set) var isUnlocked = false
    private let walletUnlocker: WalletStream
    
    init(walletUnlocker: WalletStream) {
        self.walletUnlocker = walletUnlocker
    }
    
    var mnemonic: [String]? {
        get {
            return UserDefaults.Keys.mnemonic.get()
        }
        set {
            UserDefaults.Keys.mnemonic.set(newValue)
        }
    }
    
    var didCreateWallet: Bool {
        return mnemonic != nil
    }
    
    // TODO: resolve naming conflict
    static var didCreateWallet: Bool {
        get {
            return UserDefaults.Keys.didCreateWallet.get(defaultValue: false)
        }
        set {
            UserDefaults.Keys.didCreateWallet.set(newValue)
        }
    }
}
