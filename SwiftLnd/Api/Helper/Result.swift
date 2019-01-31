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
    
    init(value: Value?, error: Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error)
        }
    }
    
    public var value: Value? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
    
    public func map<U>(_ transform: (Value) -> U) -> Result<U> {
        return flatMap { .success(transform($0)) }
    }
    
    public func flatMap<U>(_ transform: (Value) -> Result<U>) -> Result<U> {
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
