//
//  Zap
//
//  Created by Otto Suess on 15.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class TransactionAnnotationStore: Persistable {
    typealias Value = TransactionAnnotation
    
    var data = [String: TransactionAnnotation]()
    let fileName = "annotations"
    
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
    
    func hideTransaction(_ transaction: Transaction) {
        let oldAnnotation = annotation(for: transaction)
        let newAnnotation = TransactionAnnotation.lens.isHidden.set(true, oldAnnotation)
        updateAnnotation(newAnnotation, for: transaction)
    }
    
    func udpateMemo(_ memo: String?, for transaction: Transaction) {
        var memo = memo
        if memo == "" {
            memo = nil
        }
        
        let oldAnnotation = annotation(for: transaction)
        let newAnnotation = TransactionAnnotation.lens.customMemo.set(memo, oldAnnotation)
        updateAnnotation(newAnnotation, for: transaction)
    }
    
    func udpateMemo(_ memo: String?, forPaymentHash paymentHash: String) {
        data[paymentHash] = TransactionAnnotation(isHidden: false, customMemo: memo, type: nil)
        savePersistable()
    }
}
