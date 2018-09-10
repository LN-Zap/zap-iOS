//
//  Lightning
//
//  Created by Otto Suess on 15.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

final class UnconfirmedTransactionStore: Persistable {
    typealias Value = [String: OnChainUnconfirmedTransaction]

    var data = [String: OnChainUnconfirmedTransaction]()
    
    static var fileName = "unconfirmedTransactions"
    
    init() {
        loadPersistable()
    }
    
    var all: [OnChainUnconfirmedTransaction] {
        return Array(data.values)
    }
    
    func add(_ unconfirmedTransaction: OnChainUnconfirmedTransaction) {
        data[unconfirmedTransaction.id] = unconfirmedTransaction
        savePersistable()
    }
    
    func remove(confirmed transactions: [Transaction]) {
        for transaction in transactions {
            data.removeValue(forKey: transaction.id)
        }
        savePersistable()
    }
}
