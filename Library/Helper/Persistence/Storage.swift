//
//  Lightning
//
//  Created by Otto Suess on 04.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum Storage {
    public static func store<T: Encodable>(_ object: T, to filename: String) {
        guard
            let encoded = try? PropertyListEncoder().encode(object),
            let url = url(for: filename)
            else { return }
        try? encoded.write(to: url)
    }

    public static func restore<T: Decodable>(_ filename: String) -> T? {
        guard
            let url = url(for: filename),
            let data = try? Data(contentsOf: url),
            let decoded = try? PropertyListDecoder().decode(T.self, from: data) else { return nil }
        return decoded
    }

    public static func remove(_ filename: String) {
        guard
            let url = url(for: filename),
            FileManager.default.fileExists(atPath: filename)
            else { return }

        try? FileManager.default.removeItem(at: url)
    }

    private static func url(for filename: String) -> URL? {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("\(filename).plist")
    }
}
