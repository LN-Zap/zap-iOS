//
//  SwiftLnd
//
//  Created by 0 on 15.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public struct FeeEstimate {
    let total: Satoshi
    let perByte: Satoshi
}

extension FeeEstimate {
    init(estimateFeeResponse: Lnrpc_EstimateFeeResponse) {
        total = Satoshi(estimateFeeResponse.feeSat)
        perByte = Satoshi(estimateFeeResponse.feerateSatPerByte)
    }
}
