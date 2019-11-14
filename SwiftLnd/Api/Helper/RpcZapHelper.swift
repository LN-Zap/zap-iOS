//
//  SwiftLnd
//
//  Created by 0 on 07.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lndmobile
import Logger
import SwiftGRPC

/// Used for streaming remote grpc connection
func handleStreamResult<T>(_ result: ResultOrRPCError<T?>, completion: @escaping ApiCompletion<T>) throws {
    switch result {
    case .result(let value):
        guard let value = value else { return }
        completion(.success(value))
    case .error(let error):
        throw error
    }
}

/// Used for regular remote grpc connection
func createHandler<T>(_ completion: @escaping ApiCompletion<T>) -> (T?, CallResult) -> Void {
    return { (response: T?, callResult: CallResult) in
        if let response = response {
            completion(.success(response))
        } else {
            let error = LndApiError(callResult: callResult)
            completion(.failure(error))
        }
    }
}
