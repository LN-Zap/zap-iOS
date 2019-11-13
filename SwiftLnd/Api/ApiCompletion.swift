//
//  SwiftLnd
//
//  Created by Otto Suess on 31.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import SwiftGRPC

public typealias ApiCompletion<T> = (Result<T, LndApiError>) -> Void

/// Used in LightningApi & WalletApi.
/// Maps an `ApiCompletion<U>` to an `ApiCompletion<T>` with the `map` function
/// to transform lnd's raw response structs to more swifty version.
func run<T, U>(_ completion: @escaping ApiCompletion<U>, map: @escaping (T) -> U?) -> ApiCompletion<T> {
    return { input in
        completion(input.flatMap {
            if let mapped = map($0) {
                return .success(mapped)
            }
            return .failure(LndApiError.unknownError)
        })
    }
}
