//
//  Library
//
//  Created by Otto Suess on 09.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

enum Xor<A, B> {
    case first(A)
    case second(B)
    
    init(_ value: A) {
        self = .first(value)
    }
    
    init(_ value: B) {
        self = .second(value)
    }
    
    var first: A? {
        if case .first(let result) = self {
            return result
        }
        return nil
    }
    
    var second: B? {
        if case .second(let result) = self {
            return result
        }
        return nil
    }
}
