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
func map<T, U>(_ completion: @escaping ApiCompletion<U>, to transform: @escaping (T) -> U?) -> ApiCompletion<T> {
    return { input in
        switch input {
        case .success(let value):
            if let transformed = transform(value) {
                completion(.success(transformed))
            } else {
                let error = LndApiError.apiMappingFailed
                Logger.error(error)
                completion(.failure(error))
            }
        case .failure(let error):
            Logger.error(error)
            completion(.failure(error))
        }
    }
}
