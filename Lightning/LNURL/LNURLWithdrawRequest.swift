//
//  Lightning
//
//  Created by 0 on 11.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public typealias MilliSatoshi = Decimal

public struct LNURLWithdrawRequest: Decodable {
    /// a second-level url which would accept a withdrawal Lightning invoice as query parameter
    let callback: String // swiftlint:disable:this callback_naming
    /// an ephemeral secret which would allow user to withdraw funds
    let k1: String // swiftlint:disable:this identifier_name
    /// max withdrawable amount for a given user on a given service
    public let maxWithdrawable: MilliSatoshi
    /// A default withdrawal invoice description
    public let defaultDescription: String
    /// An optional field, defaults to 1 MilliSatoshi if not present, can not be less than 1 or more than `maxWithdrawable`
    public let minWithdrawable: MilliSatoshi?
}
