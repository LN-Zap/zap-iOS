//
//  Zap
//
//  Created by Otto Suess on 20.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import Logger
import SwiftGRPC

public enum LndApiError: Error, LocalizedError, Equatable {
    case invalidInput
    case walletEncrypted
    case lndNotRunning
    case localizedError(String)
    case unknownError
    case walletAlreadyUnlocked
    case transactionDust
    
    public init(callResult: CallResult) {
        switch callResult.statusCode {

        case .unimplemented:
            self = .walletEncrypted
        case .internalError:
            self = .lndNotRunning
        default:
            if
                let statusMessage = callResult.statusMessage,
                !statusMessage.isEmpty {
                self = .localizedError(statusMessage)
            } else {
                self = .unknownError
            }
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
        case .transactionDust:
            return "Transaction amount too small."
        case .invalidInput, .unknownError, .walletAlreadyUnlocked:
            return nil
        }
    }
}
