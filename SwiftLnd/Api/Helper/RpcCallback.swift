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

func run<T, U>(_ completion: @escaping ApiCompletion<U>, map: @escaping (T) -> U?) -> ApiCompletion<T> {
    return { input in
        switch input {
        case .success(let value):
            if let mapped = map(value) {
                completion(.success(mapped))
            } else {
                completion(.failure(LndApiError.unknownError))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
