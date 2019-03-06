//
//  Lightning
//
//  Created by 0 on 05.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SQLite

protocol ZapTable {
    static var table: Table { get }

    init?(row: Row)
    static func createTable(database: Connection) throws
    func insert(database: Connection) throws
}
