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
    private let completion: (Result<U, LndApiError>) -> Void
    private let compactMapping: ((T) -> U?)?
    private let mapping: ((T) -> Result<U, LndApiError>)?
    
    init(_ completion: @escaping (Result<U, LndApiError>) -> Void, transform: @escaping (T) -> U?) {
        self.completion = completion
        self.compactMapping = transform
        self.mapping = nil
    }
    
    init(_ completion: @escaping (Result<U, LndApiError>) -> Void, transform: @escaping (T) -> Result<U, LndApiError>) {
        self.completion = completion
        self.compactMapping = nil
        self.mapping = transform
    }
    
    func onError(_ error: Error) {
        print("🅾️ Callback Error:", error)
        completion(.failure(LndApiError.localizedError(error.localizedDescription)))
    }
    
    func onResponse(_ data: Data) {
        if let message = try? T.parse(from: data) {
            if let value = compactMapping?(message) {
                if !(value is Info) && !(value is GraphTopologyUpdate) {
                    print("[🍕]", value)
                }
                completion(.success(value))
            } else if let value = mapping?(message) {
                print("[🍕]", value)
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
