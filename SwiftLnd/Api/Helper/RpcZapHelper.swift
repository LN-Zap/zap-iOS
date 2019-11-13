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
import SwiftProtobuf

// MARK: - Helper Methods

/// Used to communicate with lnd running on the Phone.
final class LndCallback<T: SwiftProtobuf.Message>: NSObject, LndmobileCallbackProtocol, LndmobileRecvStreamProtocol {
    private let completion: ApiCompletion<T>

    init(_ completion: @escaping ApiCompletion<T>) {
        self.completion = completion
    }

    func onError(_ error: Error?) {
        if let error = error {
            Logger.error(error)
            completion(.failure(LndApiError(error: error)))
        } else {
            completion(.failure(.unknownError))
        }
    }

    func onResponse(_ data: Data?) {
        if let data = data,
            let result = try? T(serializedData: data) {
            completion(.success(result))
        } else {
            let result = T()
            completion(.success(result))
        }
    }
}

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
            Logger.error(error)
            completion(.failure(error))
        }
    }
}

/// Used for the mock connection
extension Result {
    init(value: Success?, error: Failure) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
}
