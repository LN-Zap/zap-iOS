//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lndmobile
import Logger
import SwiftProtobuf

/// Used to communicate with lnd running on the Phone.

final class LndCallback<T: SwiftProtobuf.Message>: NSObject, LndmobileCallbackProtocol, LndmobileRecvStreamProtocol {
    private let completion: ApiCompletion<T>

    init(_ completion: @escaping ApiCompletion<T>) {
        self.completion = completion
    }

    func onError(_ error: Error?) {
        if let error = error {
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

final class EmptyStreamCallback: NSObject, LndmobileCallbackProtocol {
    func onError(_ error: Error?) {
        guard let error = error else { return }
        Logger.error("EmptyCallback Error: \(error.localizedDescription)")
    }

    func onResponse(_ data: Data?) {
        guard let data = data else { return }
        Logger.info("EmptyCallback: \(data), '\(String(data: data, encoding: .utf8) ?? "-")'", customPrefix: "🍕")
    }
}
