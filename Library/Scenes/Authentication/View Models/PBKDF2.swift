//
//  Library
//
//  Created by 0 on 26.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import CommonCrypto
import Foundation
import Logger

/// PBKDF2 (Password-Based Key Derivation Function 2) are key derivation
/// functions with a sliding computational cost, aimed to reduce the
/// vulnerability of encrypted keys to brute force attacks.
///
/// https://en.wikipedia.org/wiki/PBKDF2
enum PBKDF2 {
    private static let derivedKeyCount = 32

    static func rounds(passwordCount: Int, saltCount: Int, seconds: TimeInterval) -> Int {
        return Int(CCCalibratePBKDF(CCPBKDFAlgorithm(kCCPBKDF2), passwordCount, saltCount, CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256), derivedKeyCount, UInt32(seconds * 1000)))
    }

    static func keyFor(password: String, salt: String, rounds: Int) -> Data? {
        guard let passwordData = password.data(using: String.Encoding.utf8) else { return nil }

        var derivedKeyData = Data(repeating: 0, count: derivedKeyCount)

        Logger.info("hashing pin. rounds: \(rounds)", customPrefix: "🔐")

        let derivationStatus = derivedKeyData.withUnsafeMutableBytes { bytes -> Int32 in
            CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, passwordData.count, salt, salt.count, CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256), UInt32(rounds), bytes.bindMemory(to: UInt8.self).baseAddress, derivedKeyCount)
        }

        if derivationStatus != 0 {
            Logger.error("pbkdf2 Error: \(derivationStatus)", customPrefix: "🔐")
            return nil
        }

        return derivedKeyData
    }
}
