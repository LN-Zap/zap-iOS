//
//  Zap
//
//  Created by Otto Suess on 19.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public enum Result<Value>: CustomStringConvertible, CustomDebugStringConvertible {
    case success(Value)
    case failure(Error)
    
    init(value: Value) {
        self = .success(value)
    }
    
    init(error: Error) {
        self = .failure(error)
    }
    
    var value: Value? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
    
    func map<U>(_ transform: (Value) -> U) -> Result<U> {
        return flatMap { .success(transform($0)) }
    }
    
    func flatMap<U>(_ transform: (Value) -> Result<U>) -> Result<U> {
        switch self {
        case let .success(value):
            return transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }

    public var description: String {
        switch self {
        case let .success(value):
            return ".success(\(value))"
        case let .failure(error):
            return ".failure(\(error))"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}

/// Helper methods to create `Result` objects from grpc results

func result<T, U>(_ callback: @escaping (Result<U>) -> Void, map: @escaping (T) -> U?) -> (T?, Error?) -> Void {
    return { (response: T?, error: Error?) in
        if let response = response,
            let value = map(response) {
            print(response)
            callback(Result<U>(value: value))
        } else if let error = error as NSError? {
            switch error.code {
            case 12:
                print(LndError.walletEncrypted)
                callback(Result<U>(error: LndError.walletEncrypted))
            case 13:
                print(LndError.walletEncrypted)
                callback(Result<U>(error: LndError.lndNotRunning))
            default:
                print(error)
                callback(Result<U>(error: error))
            }
        } else {
            print(LndError.unknownError)
            callback(Result<U>(error: LndError.unknownError))
        }
    }
}

func eventResult<T, U>(_ callback: @escaping (Result<U>) -> Void, map: @escaping (T) -> U?) -> (Bool, T?, Error?) -> Void {
    return { (_, response: T?, error: Error?) in
        result(callback, map: map)(response, error)
    }
}
