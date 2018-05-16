//
//  Zap
//
//  Created by Otto Suess on 15.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

protocol PersistenceProtocol {
    // Transactions
    var transactions: Observable<[Transaction]> { get }
    func add(transaction: Transaction)
    func remove(transaction: Transaction)
    func update(transactions: [Transaction])
    
    // Channels
    var channels: Observable<[Channel]> { get }
    func update(channels: Channel)
    
    // Address
    var addresses: Observable<String> { get }
    func add(address: String)
}
