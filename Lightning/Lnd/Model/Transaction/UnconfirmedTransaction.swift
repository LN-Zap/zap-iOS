//
//  Lightning
//
//  Created by Otto Suess on 12.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public struct UnconfirmedTransaction: Transaction, Equatable, Codable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let destinationAddress: String
}
