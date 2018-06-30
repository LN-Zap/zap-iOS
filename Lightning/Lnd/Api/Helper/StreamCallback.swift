//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

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
    private let callback: (Result<U>) -> Void
    private let mapping: (T) -> U?
    
    init(_ callback: @escaping (Result<U>) -> Void, map: @escaping (T) -> U?) {
        self.callback = callback
        self.mapping = map
    }
    
    func onError(_ error: Error) {
        print("🅾️ Callback Error:", error)
        callback(Result(error: error))
    }
    
    func onResponse(_ data: Data) {
        if let message = try? T(serializedData: data),
            let value = mapping(message) {
            
            if !(value is Info) && !(value is GraphTopologyUpdate) {
                print("✅ Callback:", value)
            }
            callback(Result(value: value))
        } else {
            onError(LndApiError.unknownError)
        }
    }
}
