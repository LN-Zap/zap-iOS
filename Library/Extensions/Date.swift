//
//  Library
//
//  Created by Otto Suess on 06.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension Date {
    var withoutTime: Date {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    func daysTo(end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: end).day ?? 0
    }

    func add(day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: self) ?? self
    }
}
