//
//  SwiftLnd
//
//  Created by 0 on 22.08.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import SwiftProtobuf

struct RestError: Codable {
    let error: String
    let code: Int
}

enum RestMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

final class LNDRest: NSObject, URLSessionDelegate {
    private let macaroon: String
    private let host: String
    private let cert: String?
    private let urlSessionConfiguration: URLSessionConfiguration

    private lazy var session: URLSession = {
        URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
    }()

    init(credentials: RPCCredentials, urlSessionConfiguration: URLSessionConfiguration) {
        macaroon = credentials.macaroon.hexadecimalString
        host = credentials.host.absoluteString
        cert = credentials.certificate
        self.urlSessionConfiguration = urlSessionConfiguration

        super.init()
    }

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
                Logger.error("\(error.localizedDescription) - \(url)")
                completion(.failure(.restNetworkError))
            } else {
                if let data = data, !data.isEmpty {
                    if let result = try? T(jsonUTF8Data: data) {
                        completion(.success(result))
                    } else if let error = try? JSONDecoder().decode(RestError.self, from: data) {
                        completion(.failure(LndApiError(statusMessage: error.error)))
                    } else {
                        completion(.failure(.unknownError))
                    }
                } else {
                    completion(.failure(.unknownError))
                }
            }
        }
        task.resume()
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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
    }
}
