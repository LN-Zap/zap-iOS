//
//  Zap
//
//  Created by Otto Suess on 21.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation

private final class Json {
    static func fetch<T: Decodable>(url: URL, completion: @escaping (T) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                print(String(describing: error))
            } else if let data = data,
                let json = try? JSONDecoder().decode(T.self, from: data) {
                completion(json)
            }
        }
        task.resume()
    }
}

final class BlockChainHeightLoader {
    private struct BlockHeightJSON: Decodable {
        let blockCount: Int
        
        private enum CodingKeys: String, CodingKey {
            case blockCount = "blockcount"
        }
    }
    
    static func run(completion: @escaping (Int) -> Void) {
        guard let url = URL(string: "https://testnet.blockexplorer.com/api/status?q=getBlockCount") else { fatalError("Invalid url") }
        Json.fetch(url: url) { (json: BlockHeightJSON) in
            completion(json.blockCount)
        }
    }
}
