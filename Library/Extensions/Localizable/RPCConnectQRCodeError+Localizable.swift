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
            return "rpc_connect_qrcode_error.btc_pay_expired".localized
        case .btcPayConfigurationBroken:
            return "rpc_connect_qrcode_error.btc_pay_configuration_broken".localized
        case .cantReadQRCode:
            return "rpc_connect_qrcode_error.cant_read_qrcode".localized
        }
    }
}
