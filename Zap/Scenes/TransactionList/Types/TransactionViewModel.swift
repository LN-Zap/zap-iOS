//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

protocol TransactionViewModel {
    var annotation: Observable<TransactionAnnotation> { get }
    var date: Date { get }
}

struct TransactionAnnotation {
    let isHidden: Bool
    let customMemo: String?
}
