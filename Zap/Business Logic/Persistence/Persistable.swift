//
//  Zap
//
//  Created by Otto Suess on 21.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

protocol Persistable: class {
    associatedtype Value: Codable
    
    var data: [String: Value] { get set }
    var fileName: String { get }
    
    func savePersistable()
    func loadPersistable()
}

extension Persistable {
    private var plistUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileName).plist")
    }
    
    func savePersistable() {
        guard
            let encoded = try? PropertyListEncoder().encode(data),
            let url = plistUrl
            else { return }
        try? encoded.write(to: url)
    }
    
    func loadPersistable() {
        guard
            let url = plistUrl,
            let data = try? Data(contentsOf: url),
            let decoded = try? PropertyListDecoder().decode(Dictionary<String, Value>.self, from: data) else { return }
        self.data = decoded
    }
}
