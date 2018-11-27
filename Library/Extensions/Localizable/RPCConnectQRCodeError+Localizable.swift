//
//  Library
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning

extension RPCConnectQRCodeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .btcPayExpired:
            return L10n.RpcConnectQrcodeError.btcPayExpired
        case .btcPayConfigurationBroken:
            return L10n.RpcConnectQrcodeError.btcPayConfigurationBroken
        case .cantReadQRCode:
            return L10n.RpcConnectQrcodeError.cantReadQrcode
        }
    }
}
