//
//  SwiftLnd
//
//  Created by Otto Suess on 31.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import LndRpc

enum WalletApiTransformation {
    static func generateSeed(input: LNDGenSeedResponse) -> [String] {
        return input.cipherSeedMnemonicArray.compactMap { $0 as? String }
    }

    static func initWallet(input: LNDInitWalletResponse) -> Success {
        return Success()
    }

    static func unlockWallet(input: LNDUnlockWalletResponse) -> Success {
        return Success()
    }
}
