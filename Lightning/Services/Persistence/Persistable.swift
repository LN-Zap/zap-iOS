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
    private static var plistUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileName).plist")
    }
    
    public func savePersistable() {
        guard
            let encoded = try? PropertyListEncoder().encode(data),
            let url = Self.plistUrl
            else { return }
        try? encoded.write(to: url)
    }
    
    public func loadPersistable() {
        if let decoded = Self.decoded {
            data = decoded
        }
    }
    
    public static var decoded: Value? {
        guard
            let url = plistUrl,
            let data = try? Data(contentsOf: url),
            let decoded = try? PropertyListDecoder().decode(Value.self, from: data) else { return nil }
        return decoded
    }
}
