//
//  SwiftLnd
//
//  Created by 0 on 07.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
#if !REMOTEONLY
import Lndmobile
#endif
import Logger
import SwiftGRPC
import SwiftProtobuf

// MARK: - Helper Methods
#if !REMOTEONLY
final class LndCallback<T: SwiftProtobuf.Message>: NSObject, LndmobileCallbackProtocol, LndmobileRecvStreamProtocol {
    private let completion: ApiCompletion<T>

    init(_ completion: @escaping ApiCompletion<T>) {
        self.completion = completion
    }

    func onError(_ error: Error) {
        Logger.error(error)
        let result: LndApiError
        if error.localizedDescription == "Closed" {
            result = .walletAlreadyUnlocked
        } else {
            result = LndApiError.localizedError(error.localizedDescription)
        }
        completion(.failure(result))
    }

    func onResponse(_ data: Data) {
        if let result = try? T(serializedData: data) {
            completion(.success(result))
        } else {
            onError(LndApiError.unknownError)
        }
    }
}
#endif

func handleStreamResult<T>(_ result: ResultOrRPCError<T?>, completion: @escaping ApiCompletion<T>) throws {
    switch result {
    case .result(let value):
        guard let value = value else { return }
        completion(.success(value))
    case .error(let error):
        throw error
    }
}

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

extension Result {
    init(value: Success?, error: Failure) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
}
