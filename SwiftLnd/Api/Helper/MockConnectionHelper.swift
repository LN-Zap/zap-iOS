//
//  SwiftLnd
//
//  Created by 0 on 13.11.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

extension Result {
    init(value: Success?, error: Failure) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
}
