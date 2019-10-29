//
//  Lightning
//
//  Created by 0 on 28.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

typealias MilliSatoshi = Decimal

struct WithdrawRequest: Decodable {
    /// a second-level url which would accept a withdrawal Lightning invoice as query parameter
    let callback: String // swiftlint:disable:this callback_naming
    /// an ephemeral secret which would allow user to withdraw funds
    let k1: String // swiftlint:disable:this identifier_name
    /// max withdrawable amount for a given user on a given service
    let maxWithdrawable: MilliSatoshi
    /// A default withdrawal invoice description
    let defaultDescription: String
    /// An optional field, defaults to 1 MilliSatoshi if not present, can not be less than 1 or more than `maxWithdrawable`
    let minWithdrawable: MilliSatoshi
}

struct LNURLStatus: Decodable {
    enum Status: String, Codable {
        case ok = "OK" // swiftlint:disable:this identifier_name
        case error = "ERROR"
    }
    
    let status: Status
    let reason: String?
}

enum LNURL {
    case withdraw(WithdrawRequest)
    
    enum LNURLError: Error {
        case invalidBech32
        case urlError(Error)
        case jsonError
    }
        
    static func parse(string: String, completion: @escaping (Result<LNURL, LNURLError>) -> Void) {
        switch decodeBech32(string: string) {
        case .success(let data):
            loadJSON(data: data, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    static func loadJSON(data: Data, completion: @escaping (Result<LNURL, LNURLError>) -> Void) {
        if let lnurl = LNURL.parseJSON(data: data) {
            completion(.success(lnurl))
        } else if let dataString = String(data: data, encoding: .utf8),
            let url = URL(string: dataString) {
            
            fetch(url: url) { result in
                switch result {
                case .success(let data):
                    if let lnurl = parseJSON(data: data) {
                        completion(.success(lnurl))
                    } else {
                        completion(.failure(.jsonError))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(.invalidBech32))
        }
    }
    
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
    
    private static func parseJSON(data: Data) -> LNURL? {
        guard
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let tag = jsonData["tag"] as? String
            else { return nil }
        
        switch tag {
        case "withdrawRequest":
            guard let withdrawRequest = try? JSONDecoder().decode(WithdrawRequest.self, from: data) else { return nil }
            return .withdraw(withdrawRequest)
        default:
            return nil
        }
    }
}
