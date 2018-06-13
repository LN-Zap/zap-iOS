//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

final class WalletService {
    
    private(set) var isUnlocked = false
    private let walletUnlocker: WalletUnlocker
    
    init(walletUnlocker: WalletUnlocker = WalletUnlocker()) {
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
    
    func unlock(callback: @escaping (Result<Void>) -> Void) {
        guard !isUnlocked else { return }
        walletUnlocker.unlockWallet { [weak self] result in
            if result.value != nil {
                self?.isUnlocked = true
                callback(Result(value: ()))
            } else {
                print("error")
            }
        }
    }
    
    func setup(callback: @escaping (Result<Void>) -> Void) {
        walletUnlocker.generateSeed { [weak self] result in
            guard let mnemonic = result.value else { return }
            self?.mnemonic = mnemonic
            self?.walletUnlocker.initWallet(mnemonic: mnemonic, callback: callback)
        }
    }
}
