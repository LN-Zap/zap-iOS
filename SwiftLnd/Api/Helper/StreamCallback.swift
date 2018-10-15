//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

#if !REMOTEONLY

import Foundation
import Lndmobile
import SwiftProtobuf

final class EmptyStreamCallback: NSObject, LndmobileCallbackProtocol {
    func onError(_ error: Error) {
        print("🅾️ EmptyCallback Error:", error)
    }
    
    func onResponse(_ data: Data) {
        print("✅ EmptyCallback:", data)
    }
}

final class StreamCallback<T: SwiftProtobuf.Message, U>: NSObject, LndmobileCallbackProtocol {
    private let completion: (Result<U>) -> Void
    private let mapping: (T) -> U?
    
    init(_ completion: @escaping (Result<U>) -> Void, map: @escaping (T) -> U?) {
        self.completion = completion
        self.mapping = map
    }
    
    func onError(_ error: Error) {
        print("🅾️ Callback Error:", error)
        completion(.failure(error))
    }
    
    func onResponse(_ data: Data) {
        if let message = try? T(serializedData: data),
            let value = mapping(message) {
            
            if !(value is Info) && !(value is GraphTopologyUpdate) {
                print("✅ Callback:", value)
            }
            completion(.success(value))
        } else {
            onError(LndApiError.unknownError)
        }
    }
}

#endif
