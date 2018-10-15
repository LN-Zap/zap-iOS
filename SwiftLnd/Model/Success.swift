//
//  Lightning
//
//  Created by Otto Suess on 24.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct Success: Equatable {
    public init() {}
    
    public static func == (lhs: Success, rhs: Success) -> Bool {
        return true
    }
}
