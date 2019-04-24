//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile
import LndRpc
import Logger

final class EmptyStreamCallback: NSObject, LndmobileCallbackProtocol {
    func onError(_ error: Error) {
        Logger.error("EmptyCallback Error: \(error.localizedDescription)")
    }

    func onResponse(_ data: Data) {
        Logger.info("EmptyCallback: \(data), '\(String(data: data, encoding: .utf8) ?? "-")'", customPrefix: "🍕")
    }
}

final class StreamCallback<T: GPBMessage, U>: NSObject, LndmobileCallbackProtocol, LndmobileRecvStreamProtocol {
    private let completion: Handler<U>
    private let compactMapping: ((T) -> U?)?
    private let mapping: ((T) -> Result<U, LndApiError>)?

    init(_ completion: @escaping Handler<U>, transform: @escaping (T) -> U?) {
        self.completion = completion
        self.compactMapping = transform
        self.mapping = nil
    }

    init(_ completion: @escaping Handler<U>, transform: @escaping (T) -> Result<U, LndApiError>) {
        self.completion = completion
        self.compactMapping = nil
        self.mapping = transform
    }

    func onError(_ error: Error) {
        Logger.error(error)
        completion(.failure(LndApiError.localizedError(error.localizedDescription)))
    }

    func onResponse(_ data: Data) {
        if let message = try? T.parse(from: data) {
            if let value = compactMapping?(message) {
                Logger.verbose(value, customPrefix: "🍕")
                completion(.success(value))
            } else if let value = mapping?(message) {
                Logger.verbose(value, customPrefix: "🍕")
                completion(value)
            } else {
                onError(LndApiError.unknownError)
            }
        } else {
            onError(LndApiError.unknownError)
        }
    }
}

#endif
