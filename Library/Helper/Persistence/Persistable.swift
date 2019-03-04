//
//  Zap
//
//  Created by Otto Suess on 21.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public protocol Persistable: class {
    associatedtype Value: Codable

    var data: Value { get set }
    static var fileName: String { get }

    func savePersistable()
    func loadPersistable()
}

extension Persistable {
    public func savePersistable() {
        Storage.store(data, to: Self.fileName)
    }

    public func loadPersistable() {
        if let decoded = Self.decoded {
            data = decoded
        }
    }

    public static var decoded: Value? {
        return Storage.restore(Self.fileName)
    }
}
