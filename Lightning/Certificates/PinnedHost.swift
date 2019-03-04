//
//  Lightning
//
//  Created by Otto Suess on 24.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct PinnedHost {
    let host: String
    let publicKeys: [SecKey]

    init(named host: String, certificates: [String]) {
        self.host = host

        publicKeys = certificates.map {
            guard
                let path = Bundle(for: PinnedURLSessionDelegate.self).path(forResource: $0, ofType: ".cer"),
                let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) as CFData,
                let certificate = SecCertificateCreateWithData(nil, certificateData),
                let publicKey = PinnedURLSessionDelegate.publicKey(for: certificate)
                else { fatalError("Could not load certificate named: \($0) for host: \(host)") }
            return publicKey
        }
    }
}
