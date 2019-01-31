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

final class EmptyStreamCallback: NSObject, LndmobileCallbackProtocol {
    func onError(_ error: Error) {
        print("🅾️ EmptyCallback Error:", error)
    }
    
    func onResponse(_ data: Data) {
        print("✅ EmptyCallback:", data)
    }
}

final class StreamCallback<T: GPBMessage, U>: NSObject, LndmobileCallbackProtocol {
    private let completion: (Result<U>) -> Void
    private let compactMapping: ((T) -> U?)?
    private let mapping: ((T) -> Result<U>)?
    
    init(_ completion: @escaping (Result<U>) -> Void, map: @escaping (T) -> U?) {
        self.completion = completion
        self.compactMapping = map
        self.mapping = nil
    }
    
    init(_ completion: @escaping (Result<U>) -> Void, map: @escaping (T) -> Result<U>) {
        self.completion = completion
        self.compactMapping = nil
        self.mapping = map
    }
    
    func onError(_ error: Error) {
        print("🅾️ Callback Error:", error)
        completion(.failure(error))
    }
    
    func onResponse(_ data: Data) {
        if let message = try? T.parse(from: data) {
            if let value = compactMapping?(message) {
                completion(.success(value))
            } else if let value = mapping?(message) {
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
