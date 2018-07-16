//
//  Lightning
//
//  Created by Otto Suess on 16.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

private extension String {
    func separate(every: Int, with separator: String) -> String {
        let result = stride(from: 0, to: count, by: every)
            .map { Array(Array(self)[$0..<min($0 + every, count)]) }
            .joined(separator: separator)
        return String(result)
    }
}

class Pem {
    private let prefix = "-----BEGIN CERTIFICATE-----"
    private let suffix = "-----END CERTIFICATE-----"
    let string: String
    
    init(key: String) {
        if key.hasPrefix(prefix) {
            string = key
        } else {
            string = "\(prefix)\n\(key.separate(every: 64, with: "\n"))\n\(suffix)\n"
        }
    }
}
