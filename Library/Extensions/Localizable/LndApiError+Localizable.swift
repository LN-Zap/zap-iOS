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
        case .unlocalized(let description):
            return description
        case .walletEncrypted:
            return L10n.LndError.walletEncrypted
        case .lndNotRunning:
            return L10n.LndError.lndNotRunning
        case .transactionOutputIsDust:
            return L10n.LndError.transactionOutputIsDust
        case .noOutputs:
            return L10n.LndError.noOutputs
        case .restNetworkError:
            return L10n.LndError.restNetworkError
        case .unableToFindNode:
            return L10n.LndError.unableToFindNode
        case .unknownError:
            return L10n.LndError.unknownError
        case .apiMappingFailed:
            return L10n.LndError.apiTransformationError
        case .insufficientFundsAvailable:
            return L10n.LndError.insufficientFundsAvailable
        case .invoiceAlreadyPaid:
            return L10n.LndError.invoiceAlreadyPaid
        case .noPathToDestination:
            return L10n.LndError.noPathToDestination
        }
    }
}
