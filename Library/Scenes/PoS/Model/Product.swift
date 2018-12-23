//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

protocol Groupable {
    var name: String { get }
}

struct Group: Groupable {
    let name: String
    let items: [Groupable]
}

struct Product: Groupable, Equatable, Hashable {
    let name: String
    let price: Decimal
}
