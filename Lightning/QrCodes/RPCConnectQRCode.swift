//
//  Lightning
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

public enum RPCConnectQRCodeError: Error {
    case btcPayExpired
    case btcPayConfigurationBroken
    case cantReadQRCode
}

/// Decodes RPCConfiguration from lndconnect, zapconnect & BTCPay QRCodes
public enum RPCConnectQRCode {
    public static func configuration(for string: String, completion: @escaping (Result<RemoteRPCConfigurationType>) -> Void) {
        if let url = URL(string: string),
            let lndConnectURL = LndConnectURL(url: url) {
            completion(.success(lndConnectURL))
        } else if let qrCode = ZapconnectQRCode(json: string) {
            completion(.success(qrCode))
        } else if let btcPayQRCode = BTCPayQRCode(string: string) {
            btcPayQRCode.fetchConfiguration { result in
                let mappedResult = result.flatMap { configData -> Result<RemoteRPCConfigurationType> in
                    if let configuration = BTCPayRPCConfiguration(data: configData) {
                        return .success(configuration)
                    } else {
                        return .failure(RPCConnectQRCodeError.btcPayConfigurationBroken)
                    }
                }
                completion(mappedResult)
            }
        } else {
            completion(.failure(RPCConnectQRCodeError.cantReadQRCode))
        }
    }
}
