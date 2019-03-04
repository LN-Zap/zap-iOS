//
//  Zap
//
//  Created by Otto Suess on 20.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public enum LndApiError: Error, LocalizedError, Equatable {
    case invalidInput
    case walletEncrypted
    case lndNotRunning
    case localizedError(String)
    case unknownError

    public init(error: NSError) {
        switch error.code {
        case 12:
            self = .walletEncrypted
        case 13:
            self = .lndNotRunning
        default:
            self = .localizedError(error.localizedDescription)
        }
    }

    public var errorDescription: String? {
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
