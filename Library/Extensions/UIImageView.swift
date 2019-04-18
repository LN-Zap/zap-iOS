//
//  Library
//
//  Created by 0 on 10.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

extension UIImageView {
    func download(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType,
                mimeType.hasPrefix("image"),
                let data = data,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
