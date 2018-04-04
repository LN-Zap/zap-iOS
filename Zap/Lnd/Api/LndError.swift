//
//  Zap
//
//  Created by Otto Suess on 20.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

enum LndError: Error, LocalizedError {
    case invalidInput
    case walletEncrypted
    case lndNotRunning
    case localizedError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .localizedError(let description):
            return description
        case .walletEncrypted:
            return "Wallet is encrypted."
        case .lndNotRunning:
            return "Lnd does not seem to be running properly."
        case .invalidInput, .unknownError:
            return nil
        }
    }
}
