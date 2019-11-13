//
//  Lightning
//
//  Created by 0 on 11.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

typealias MilliSatoshi = Decimal

struct LNURLWithdrawRequestJSON: Decodable {
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

public extension Satoshi {
    var floored: Satoshi {
        var value = self
        var result: Decimal = 0
        NSDecimalRound(&result, &value, 0, .down)
        return result
    }
}

public struct LNURLWithdrawRequest {
    let callbackURL: String
    let ephemeralSecret: String
    public let description: String
    public let maxWithdrawable: Satoshi
    public let minWithdrawable: Satoshi
    
    public let domain: URL?
    
    init(lnurlWithdrawRequestJSON request: LNURLWithdrawRequestJSON, domain: URL?) {
        callbackURL = request.callback
        ephemeralSecret = request.k1
        description = request.defaultDescription
        
        maxWithdrawable = (request.maxWithdrawable / 1000).floored
        
        if let minWithdrawable = request.minWithdrawable {
            self.minWithdrawable = (minWithdrawable / 1000).floored
        } else {
            minWithdrawable = 1
        }
        
        self.domain = domain
    }
}
