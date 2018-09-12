//
//  Lightning
//
//  Created by Otto Suess on 11.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite

extension Satoshi: Value {
    public typealias Datatype = String
    
    public static var declaredDatatype = String.declaredDatatype
    
    public static func fromDatatypeValue(_ datatypeValue: String) -> Satoshi {
        guard let value = Satoshi(string: datatypeValue) else { fatalError("Error decoding decimal value") }
        return value
    }
    
    public var datatypeValue: String {
        var satoshi = self
        return NSDecimalString(&satoshi, nil)
    }
}
