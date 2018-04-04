//
//  Zap
//
//  Created by Otto Suess on 29.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

extension Array {
    func grouped<T>(by criteria: (Element) -> T) -> [T: [Element]] {
        var groups = [T: [Element]]()
        for element in self {
            let key = criteria(element)
            if !groups.keys.contains(key) {
                groups[key] = [Element]()
            }
            groups[key]?.append(element)
        }
        return groups
    }
}
