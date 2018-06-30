//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

struct Section<T> {
    let title: String?
    private let rows: [T]
    
    init(title: String?, rows: [T]) {
        self.title = title
        self.rows = rows
    }
    
    var count: Int {
        return rows.count
    }
    
    subscript(index: Int) -> T {
        return rows[index]
    }
}
