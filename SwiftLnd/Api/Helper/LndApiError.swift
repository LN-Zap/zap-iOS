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
    case apiTransformationError
    case restNetworkError
    
    case unableToFindNode
    case transactionOutputIsDust
    case noOutputs
    case insufficientFundsAvailable
    
    // map local streaming connetion to error
    init(error: Error) {
        let message = error.localizedDescription.deletingPrefix("rpc error: code = Unknown desc = ")
        self = .init(statusMessage: message)
    }
    
    // map remote grpc connection to error
    init(callResult: CallResult) {
        switch callResult.statusCode {

        case .unimplemented:
            self = .walletEncrypted
        case .internalError:
            self = .lndNotRunning
        default:
            if let statusMessage = callResult.statusMessage, !statusMessage.isEmpty {
                self = .init(statusMessage: statusMessage)
            } else {
                self = .unknownError
            }
        }
    }
    
    init(statusMessage: String) {
        switch statusMessage {
        case "unable to find node":
            self = .unableToFindNode
        case "transaction output is dust":
            self = .transactionOutputIsDust
        case "no outputs":
            self = .noOutputs
        case "insufficient funds available to construct transaction":
            self = .insufficientFundsAvailable
        default:
            self = .localizedError(statusMessage)
        }
    }
}
