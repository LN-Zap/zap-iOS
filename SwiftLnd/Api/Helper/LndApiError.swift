//
//  Zap
//
//  Created by Otto Suess on 20.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftGRPC

public enum LndApiError: Error, Equatable {
    case walletEncrypted
    case lndNotRunning
    case localizedError(String)
    case unknownError
    case walletAlreadyUnlocked

    // map local streaming connetion to error
    init(error: Error) {
        if error.localizedDescription == "Closed" {
            self = .walletAlreadyUnlocked
        } else {
            self = LndApiError.localizedError(error.localizedDescription)
        }
    }
    
    // map remote grpc connection to error
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
