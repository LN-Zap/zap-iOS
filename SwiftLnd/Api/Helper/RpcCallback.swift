//
//  SwiftLnd
//
//  Created by Otto Suess on 31.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

/// Helper methods to execute callbacks with `Result` objects from grpc results.

// Most of the time when the grpc call returns a type T the map function
// succeeds so we can just return U without wrapping it in a result.
func createHandler<T, U>(_ completion: @escaping (Result<U, LndApiError>) -> Void, map: @escaping (T) -> U?) -> (T?, Error?) -> Void {
    let map = { (response: T) -> Result<U, LndApiError> in
        if let value = map(response) {
            return .success(value)
        } else {
            print(LndApiError.unknownError)
            return .failure(LndApiError.unknownError)
        }
    }
    return createHandler(completion, map: map)
}

// In special cases the mapping fails even when the grpc call returns a type T.
// (e.g. `SendResponse` contains a `payment_error` property)
func createHandler<T, U>(_ completion: @escaping (Result<U, LndApiError>) -> Void, map: @escaping (T) -> Result<U, LndApiError>) -> (T?, Error?) -> Void {
    return { (response: T?, error: Error?) in
        if let response = response {
            completion(map(response))
        } else if let error = error as NSError? {
            switch error.code {
            case 12:
                print(LndApiError.walletEncrypted)
                completion(.failure(LndApiError.walletEncrypted))
            case 13:
                print(LndApiError.lndNotRunning)
                completion(.failure(LndApiError.lndNotRunning))
            default:
                print(error)
                completion(.failure(LndApiError.localizedError(error.localizedDescription)))
            }
        }
    }
}

// event results have an extra `Bool` argument that we just ignore.
func createHandler<T, U>(_ completion: @escaping (Result<U, LndApiError>) -> Void, map: @escaping (T) -> U?) -> (Bool, T?, Error?) -> Void {
    return { (_, response: T?, error: Error?) in
        createHandler(completion, map: map)(response, error)
    }
}
