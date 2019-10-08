//
//  SwiftLnd
//
//  Created by 0 on 22.08.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import SwiftProtobuf

enum RestMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

final class LNDRest: NSObject, URLSessionDelegate {
    private let macaroon: String
    private let host: String
    private let cert: String?

    private var torTest: OnionManager?
    static var torSession: URLSession?

    init(credentials: RPCCredentials) {
        macaroon = credentials.macaroon.hexadecimalString
        host = credentials.host.absoluteString
        cert = credentials.certificate

        super.init()
        setupTor()
    }

    func setupTor() {
        if LNDRest.torSession == nil {
            torTest = OnionManager.shared
            torTest?.startTor(delegate: self)
        }
    }

    lazy var session: URLSession = {
        if let torSession = LNDRest.torSession {
            return torSession
        } else {
            let configuration = URLSessionConfiguration.default
            return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
    }()

    func run<T: Message>(method: RestMethod, path: String, data: String?, completion: @escaping (Result<T, LndApiError>) -> Void) {
        guard let url = URL(string: "https://\(host)\(path)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(macaroon, forHTTPHeaderField: "Grpc-Metadata-macaroon")

        if let data = data {
            request.httpBody = data.data(using: .utf8)
        }

        let task = session.dataTask(with: request) { data, _, error in
            if let error = error {
                Logger.error(error.localizedDescription)
                completion(.failure(.localizedError(error.localizedDescription)))
            } else {
                if let data = data {
                    if let result = try? T(jsonUTF8Data: data) {
                        completion(.success(result))
                    } else if let string = String(data: data, encoding: .utf8) {
                        Logger.error(string)
                        completion(.failure(.localizedError(string)))
                    }
                }
            }
        }
        task.resume()
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        // don't check tls certificate
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
        }

        /*
        guard let trust = challenge.protectionSpace.serverTrust else { return }
        let credential = URLCredential(trust: trust)

        if let certificate = cert,
            let remoteCert = SecTrustGetCertificateAtIndex(trust, 0) {
            let remoteCertData = SecCertificateCopyData(remoteCert) as NSData

            let cert = certificate
                .components(separatedBy: "\n")
                .filter { !$0.isEmpty }
                .dropLast()
                .dropFirst()
                .joined()
            let certData = Data(base64Encoded: cert)

            if let pinnedCertData = certData,
                remoteCertData.isEqual(to: pinnedCertData as Data) {
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.rejectProtectionSpace, nil)
            }
        } else {
            completionHandler(.useCredential, credential)
        }
         */
    }
}

extension LNDRest: OnionManagerDelegate {
    func torConnProgress(_ progress: Int) {
        Logger.info("\(progress)")
    }

    func torConnFinished(configuration: URLSessionConfiguration) {
        LNDRest.torSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    func torConnError() {
        Logger.error("torConnError")
    }
}
