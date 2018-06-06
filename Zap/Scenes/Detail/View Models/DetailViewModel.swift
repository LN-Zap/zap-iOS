//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

protocol DetailViewModel {
    var detailViewControllerTitle: String { get }
    var detailCells: MutableObservableArray<DetailCellType> { get }
}
