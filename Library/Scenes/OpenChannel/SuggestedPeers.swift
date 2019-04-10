//
//  Library
//
//  Created by 0 on 09.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

struct SuggestedPeers: Decodable {
    private static let url = URL(string: "http://zap.jackmallers.com/api/v1/suggested-peers")! // swiftlint:disable:this force_unwrapping

    struct Currency: Decodable {
        struct Peer: Decodable {
            let pubkey: String
            let host: URL
            let nickname: String
            let description: String
            let image: URL
        }

        let mainnet: [Peer]
        let testnet: [Peer]
    }

    let bitcoin: Currency

    static func load(for network: Network, completion: @escaping ([SuggestedPeers.Currency.Peer]) -> Void) {
        DispatchQueue.global().async {
            guard
                let data = try? Data(contentsOf: SuggestedPeers.url),
                let suggestedPeers = try? JSONDecoder().decode(SuggestedPeers.self, from: data)
                else { return }

            switch network {
            case .regtest:
                completion([])
            case .testnet:
                completion(suggestedPeers.bitcoin.testnet)
            case .mainnet:
                completion(suggestedPeers.bitcoin.mainnet)
            }
        }
    }
}
