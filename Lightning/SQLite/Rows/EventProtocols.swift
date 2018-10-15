//
//  Lightning
//
//  Created by Otto Suess on 19.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public protocol DateProvidingEvent {
    var date: Date { get }
}

public protocol AmountProvidingEvent {
    var amount: Satoshi { get }
}

public typealias PlottableEvent = DateProvidingEvent & AmountProvidingEvent
