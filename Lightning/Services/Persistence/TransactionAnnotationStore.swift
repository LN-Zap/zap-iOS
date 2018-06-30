//
//  Zap
//
//  Created by Otto Suess on 15.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

public final class TransactionAnnotationStore: Persistable {
    public typealias Value = [String: TransactionAnnotation]
    
    public var data = [String: TransactionAnnotation]()
    public static let fileName = "annotations"
    
    public init() {
        loadPersistable()
    }
    
    public func annotation(for transaction: Transaction) -> TransactionAnnotation {
        return data[transaction.id] ?? TransactionAnnotation()
    }
    
    public func updateAnnotation(_ annotation: TransactionAnnotation, for transaction: Transaction) {
        data[transaction.id] = annotation
        savePersistable()
    }
    
    public func hideTransaction(_ transaction: Transaction) {
        let oldAnnotation = annotation(for: transaction)
        let newAnnotation = oldAnnotation.settingHidden(to: true)
        updateAnnotation(newAnnotation, for: transaction)
    }
    
    func udpateMemo(_ memo: String?, for transaction: Transaction) {
        var memo = memo
        if memo == "" {
            memo = nil
        }
        
        let oldAnnotation = annotation(for: transaction)
        let newAnnotation = oldAnnotation.settingMemo(to: memo) 
        updateAnnotation(newAnnotation, for: transaction)
    }
    
    public func udpateMemo(_ memo: String?, forPaymentHash paymentHash: String) {
        data[paymentHash] = TransactionAnnotation(isHidden: false, customMemo: memo, type: nil)
        savePersistable()
    }
}
