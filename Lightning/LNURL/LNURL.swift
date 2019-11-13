//
//  Lightning
//
//  Created by 0 on 28.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC
import SwiftLnd

private extension String {
    var isValidURL: Bool {
        if
            let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
            let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

public enum LNURL {
    case withdraw(LNURLWithdrawRequest)
    
    public enum LNURLError: Error {
        case invalidBech32
        case urlError(Error)
        case jsonError
        case statusError(String)
        case unknownError
        case unsupported
        
        init?(status: LNURLStatus) {
            guard
                status.status == .error,
                let reason = status.reason
                else { return nil }
            self = .statusError(reason)
        }
    }
        
    public static func parse(string: String, completion: @escaping (Result<LNURL, LNURLError>) -> Void) {
        switch decodeBech32(string: string) {
        case .success(let data):
            loadJSON(data: data, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    private static func loadJSON(data: Data, completion: @escaping (Result<LNURL, LNURLError>) -> Void) {
        if let dataString = String(data: data, encoding: .utf8),
            dataString.isValidURL,
            let url = URL(string: dataString) {
            
            fetch(url: url) { result in
                switch result {
                case .success(let data):
                    completion(parseJSON(data: data, domain: url))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(parseJSON(data: data, domain: nil))
        }
    }
    
    // internal to make tests work
    internal static func decodeBech32(string: String) -> Result<Data, LNURLError> {
        if let (hrp, data) = Bech32.decode(string, limit: false),
            hrp == "lnurl",
            let convertedData = data.convertBits(fromBits: 5, toBits: 8, pad: false) {
            return .success(convertedData)
        } else {
            return .failure(.invalidBech32)
        }
    }
    
    private static func fetch(url: URL, completion: @escaping (Result<Data, LNURLError>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(.urlError(error)))
            } else if let data = data {
                completion(.success(data))
            }
        }
        task.resume()
    }
    
    private static func parseJSON(data: Data, domain: URL?) -> Result<LNURL, LNURLError> {
        if
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let tag = jsonData["tag"] as? String {
            switch tag {
            case "withdrawRequest":
                guard let withdrawRequestJSON = try? JSONDecoder().decode(LNURLWithdrawRequestJSON.self, from: data) else { return .failure(.unknownError) }
                return .success(.withdraw(LNURLWithdrawRequest(lnurlWithdrawRequestJSON: withdrawRequestJSON, domain: domain)))
            default:
                return .failure(.unsupported)
            }
        } else if
            let status = try? JSONDecoder().decode(LNURLStatus.self, from: data),
            let error = LNURLError(status: status) {
            return .failure(error)
        }
        
        return .failure(.unknownError)
    }
}

// MARK: - Withdraw
extension LNURL {
    public static func withdraw(lightningService: LightningService, request: LNURLWithdrawRequest, amount: Satoshi, completion: @escaping (Result<Success, LNURLError>) -> Void) {
        lightningService.transactionService.addInvoice(amount: amount, memo: request.description, expiry: .oneHour) { result in
            switch result {
            case .success(let invoice):
                // Once accepted user software issues an HTTPS GET request using <callback>?k1=<k1>&pr=<lightning invoice, ...>.
                let urlString = "\(request.callbackURL)?k1=\(request.ephemeralSecret)&pr=\(invoice)"
                if let url = URL(string: urlString) {
                    LNURL.fetch(url: url) {
                        completion($0.flatMap {
                            if let status = try? JSONDecoder().decode(LNURLStatus.self, from: $0) {
                                if let error = LNURLError(status: status) {
                                    return .failure(error)
                                } else {
                                    return .success(Success())
                                }
                            } else {
                                return .failure(.jsonError)
                            }
                        })
                    }
                } else {
                    completion(.failure(.unknownError))
                }
            case .failure:
                completion(.failure(.unknownError))
            }
        }
    }
}
