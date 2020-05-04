//
//  Zap
//
//  Created by Otto Suess on 21.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import Logger
import SwiftBTC

protocol HeightJsonProtocol: Decodable {
    var height: Int { get }
}

enum BlockchainHeight: CaseIterable {
    case blockcypher
    case blockstream

    static func get(for network: Network, completion: @escaping (Int) -> Void) {
        var isFirstResponse = true

        let firstCompletion = { (explorer: BlockchainHeight, height: Int) in
            if isFirstResponse {
                isFirstResponse = false
                Logger.info("\(explorer) \(height)")
                completion(height)
            }
        }

        BlockchainHeight.allCases.forEach { explorer in
            explorer.getBlockHeight(network: network) {
                firstCompletion(explorer, $0)
            }
        }
    }

    // MARK: - private

    private func url(for network: Network) -> URL {
        // swiftlint:disable force_unwrapping
        switch self {
        case .blockcypher:
            let prefix = network == .mainnet ? "main" : "test3"
            return URL(string: "https://api.blockcypher.com/v1/btc/\(prefix)")!
        case .blockstream:
            let prefix = network == .mainnet ? "api" : "testnet/api"
            return URL(string: "https://blockstream.info/\(prefix)/blocks/tip/height")!
        }
        // swiftlint:enable force_unwrapping
    }

    private func getBlockHeight(network: Network, completion: @escaping (Int) -> Void) {
        switch self {
        case .blockcypher:
            fetch(url: url(for: network), completion: completion) {
                $0["height"] as? Int
            }
        case .blockstream:
            fetch(url: url(for: network), completion: completion)
        }
    }

    private func fetch(url: URL, completion: @escaping (Int) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                Logger.error(error)
            } else if let data = data,
                let string = String(data: data, encoding: .utf8),
                let height = Int(string) {
                completion(height)
            }
        }
        task.resume()
    }

    private func fetch(url: URL, completion: @escaping (Int) -> Void, map: @escaping ([String: Any]) -> Int?) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                Logger.error(error)
            } else if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dictionary = json as? [String: Any],
                let height = map(dictionary) {
                completion(height)
            }
        }
        task.resume()
    }
}
