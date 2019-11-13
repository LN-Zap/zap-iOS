//
//  Library
//
//  Created by 0 on 13.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

extension LndApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .localizedError(let description):
            return description
        case .walletEncrypted:
            return "Wallet is encrypted."
        case .lndNotRunning:
            return "Lnd does not seem to be running properly."
        case .transactionOutputIsDust:
            return "Transaction output is dust."
        case .noOutputs:
            return "No outputs."
        case
             .unableToFindNode,
             .unknownError,
             .apiTransformationError:
            return "Unknown Error."
        }
    }
}
