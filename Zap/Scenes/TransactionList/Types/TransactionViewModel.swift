//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

protocol TransactionViewModel {
    var id: String { get }
    var annotation: Observable<TransactionAnnotation> { get }
    var date: Date { get }
    var detailViewControllerTitle: String { get }
    var data: MutableObservableArray<DetailCellType> { get }
}
