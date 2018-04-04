//
//  Zap
//
//  Created by Otto Suess on 22.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

extension GRPCProtoCall {
    func runWithMacaroon() {
        requestHeaders["macaroon"] = Lnd.instance.macaroon
        start()
    }
}
