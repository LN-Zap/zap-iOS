//
//  SwiftLnd
//
//  Created by Otto Suess on 31.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import LndRpc

extension GRPCProtoCall {
    func runWithMacaroon(_ macaroon: String) {
        requestHeaders["macaroon"] = macaroon
        start()
    }
}
