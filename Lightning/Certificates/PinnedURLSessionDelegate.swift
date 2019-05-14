//
//  Lightning
//
//  Created by Otto Suess on 24.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Logger

public extension URLSession {
    static var pinned: URLSession {
        return URLSession(configuration: .default, delegate: PinnedURLSessionDelegate.shared, delegateQueue: nil)
    }
}

final class PinnedURLSessionDelegate: NSObject {
    static let shared = PinnedURLSessionDelegate()
    private let hosts: [PinnedHost]

    override private init() {
        hosts = [
            PinnedHost(named: "bitcoinaverage.com", certificates: ["*.bitcoinaverage.com", "Sectigo RSA Domain Validation Secure Server CA 2"]),
            PinnedHost(named: "blockchain.info", certificates: ["www.blockchain.com", "DigiCert SHA2 Extended Validation Server CA"]),
            PinnedHost(named: "blockcypher.com", certificates: ["*.blockcypher.com", "Sectigo RSA Domain Validation Secure Server CA"]),
            PinnedHost(named: "blockexplorer.com", certificates: ["blockexplorer.com", "CloudFlare Inc ECC CA-2"]),
            PinnedHost(named: "blockstream.info", certificates: ["blockstream.info", "Let's Encrypt Authority X3"])
        ]
    }

    private func isTrustValid(_ trust: SecTrust) -> Bool {
        var result = SecTrustResultType.invalid
        let status = SecTrustEvaluate(trust, &result)
        return status == errSecSuccess && (result == .unspecified || result == .proceed)
    }

    private func pinnedHost(for string: String) -> PinnedHost? {
        return hosts.first(where: { string.hasSuffix($0.host) })
    }

    private func evaluate(_ serverTrust: SecTrust, forHost host: String) -> Bool {
        guard
            let pinnedHost = self.pinnedHost(for: host),
            isTrustValid(serverTrust)
            else { return false }

        let policy = SecPolicyCreateSSL(true, host as CFString)
        SecTrustSetPolicies(serverTrust, policy)

        for serverPublicKey in publicKeys(for: serverTrust) as [AnyObject] {
            for pinnedPublicKey in pinnedHost.publicKeys {
                if serverPublicKey.isEqual(pinnedPublicKey) {
                    return true
                } else {
                    Logger.warn("expired key for host: \(host)")
                }
            }
        }

        return false
    }

    // MARK: - Private - Public Key Extraction

    private func publicKeys(for trust: SecTrust) -> [SecKey] {
        var publicKeys: [SecKey] = []

        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index),
                let publicKey = PinnedURLSessionDelegate.publicKey(for: certificate) {
                publicKeys.append(publicKey)
            }
        }

        return publicKeys
    }

    static func publicKey(for certificate: SecCertificate) -> SecKey? {
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)

        if let trust = trust,
            trustCreationStatus == errSecSuccess {
            return SecTrustCopyPublicKey(trust)
        }

        return nil
    }
}

extension PinnedURLSessionDelegate: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let trust = challenge.protectionSpace.serverTrust,
            evaluate(trust, forHost: challenge.protectionSpace.host) {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            Logger.error("certificate error")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
