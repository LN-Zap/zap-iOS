//
//  Zap
//
//  Created by Otto Suess on 20.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftGRPC

public enum LndApiError: Error, Equatable {
    case invalidInput
    case walletEncrypted
    case lndNotRunning
    case localizedError(String)
    case unknownError
    case walletAlreadyUnlocked

    init(error: Error) {
        if error.localizedDescription == "Closed" {
            self = .walletAlreadyUnlocked
        } else {
            self = LndApiError.localizedError(error.localizedDescription)
        }
    }
    
    init(callResult: CallResult) {
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
}
