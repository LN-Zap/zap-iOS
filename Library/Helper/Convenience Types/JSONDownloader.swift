//
//  Library
//
//  Created by Otto Suess on 11.01.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

enum JSONDownloader {
    static func get<T: Decodable>(from url: URL, urlSession: URLSession = URLSession.shared, completion: @escaping (Result<T>) -> Void) {
        let task = urlSession.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                let result = try? JSONDecoder().decode(T.self, from: data) {
                completion(.success(result))
            }
        }
        task.resume()
    }
}
