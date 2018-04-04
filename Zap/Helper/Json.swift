//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

final class Json {
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
