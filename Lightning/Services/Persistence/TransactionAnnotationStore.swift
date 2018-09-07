//
//  Zap
//
//  Created by Otto Suess on 15.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class TransactionAnnotationStore: Persistable {
    typealias Value = [String: TransactionAnnotation]
    
    var data = [String: TransactionAnnotation]()
    static let fileName = "annotations"
    
    init() {
        loadPersistable()
    }
    
    func annotation(for transaction: Transaction) -> TransactionAnnotation {
        return data[transaction.id] ?? TransactionAnnotation()
    }
    
    func updateAnnotation(_ annotation: TransactionAnnotation, for transaction: Transaction) {
        data[transaction.id] = annotation
        savePersistable()
    }
    
    func setTransactionHidden(_ transaction: Transaction, hidden: Bool) -> TransactionAnnotation {
        let oldAnnotation = annotation(for: transaction)
        let newAnnotation = oldAnnotation.settingHidden(to: hidden)
        updateAnnotation(newAnnotation, for: transaction)
        return newAnnotation
    }
    
    private func udpateMemo(_ memo: String?, for transaction: Transaction) {
        var memo = memo
        if memo == "" {
            memo = nil
        }
        
        let oldAnnotation = annotation(for: transaction)
        let newAnnotation = oldAnnotation.settingMemo(to: memo) 
        updateAnnotation(newAnnotation, for: transaction)
    }
    
    func udpateMemo(_ memo: String?, forTransactionId transactionId: String) {
        let annotation = data[transactionId] ?? TransactionAnnotation()
        data[transactionId] = annotation.settingMemo(to: memo)
        savePersistable()
    }
}
