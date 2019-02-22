//
//  SwiftLnd
//
//  Created by Otto Suess on 31.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger

public typealias Handler<T> = (Result<T, LndApiError>) -> Void

/// Helper methods to execute callbacks with `Result` objects from grpc results.

// Most of the time when the grpc call returns a type T the map function
// succeeds so we can just return U without wrapping it in a result.
func createHandler<T, U>(_ completion: @escaping Handler<U>, transform: @escaping (T) -> U?) -> (T?, Error?) -> Void {
    let map = { (response: T) -> Result<U, LndApiError> in
        if let value = transform(response) {
            return .success(value)
        } else {
            Logger.error(LndApiError.unknownError)
            return .failure(LndApiError.unknownError)
        }
    }
    return createHandler(completion, transform: map)
}

// In special cases the mapping fails even when the grpc call returns a type T.
// (e.g. `SendResponse` contains a `payment_error` property)
func createHandler<T, U>(_ completion: @escaping Handler<U>, transform: @escaping (T) -> Result<U, LndApiError>) -> (T?, Error?) -> Void {
    return { (response: T?, error: Error?) in
        if let response = response {
            completion(transform(response))
        } else if let error = error as NSError? {
            let error = LndApiError(error: error)
            Logger.error(error)
            completion(.failure(error))
        }
    }
}

// event results have an extra `Bool` argument that we just ignore.
func createHandler<T, U>(_ completion: @escaping Handler<U>, transform: @escaping (T) -> U?) -> (Bool, T?, Error?) -> Void {
    return { (_, response: T?, error: Error?) in
        createHandler(completion, transform: transform)(response, error)
    }
}
