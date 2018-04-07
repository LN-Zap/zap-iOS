//
//  Zap
//
//  Created by Otto Suess on 07.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

extension NSNotification.Name {
    static let TransactionMetadataChanged = Notification.Name("TransactionMetadataChanged")
}

struct TransactionMetadata {
    let memo: String?
    let fundingChannelAlias: String?
}

protocol TransactionMetadataStore {
    func metadata(for transaction: Transaction) -> TransactionMetadata?
    func setMetadata(_ memo: TransactionMetadata, for transaction: Transaction)
 }

final class MemoryTransactionMetadataStore: TransactionMetadataStore {
    static let instance = MemoryTransactionMetadataStore()
    
    private init() {}
    
    private var dictionary = [String: TransactionMetadata]()
    
    func metadata(for transaction: Transaction) -> TransactionMetadata? {
        
        return dictionary[transaction.id]
    }
    
    func setMetadata(_ metadata: TransactionMetadata, for transaction: Transaction) {
        print("☄️", transaction, metadata)
        dictionary[transaction.id] = metadata
        
        NotificationCenter.default.post(name: .TransactionMetadataChanged, object: nil, userInfo: [
            "transaction": transaction,
            "metadata": metadata])
    }
}
