//
//  BTCUtil
//
//  Created by Otto Suess on 10.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct NotificationKeyPair {
    public static let manager: EllipticCurveKeyPair.Manager = {
        let publicAccessControl = EllipticCurveKeyPair.AccessControl(
            protection: kSecAttrAccessibleAlwaysThisDeviceOnly,
            flags: [])
        let privateAccessControl = EllipticCurveKeyPair.AccessControl(
            protection: kSecAttrAccessibleAlways,
            flags: [])
        let config = EllipticCurveKeyPair.Config(
            publicLabel: "zap.notification.public",
            privateLabel: "zap.notification.private",
            operationPrompt: nil,
            publicKeyAccessControl: publicAccessControl,
            privateKeyAccessControl: privateAccessControl,
            token: .keychain)
        return EllipticCurveKeyPair.Manager(config: config)
    }()
}
