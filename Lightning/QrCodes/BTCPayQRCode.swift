//
//  Lightning
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct BTCPayQRCode {
    let configURL: URL
    
    init?(string: String) {
        let prefix = "config="
        guard string.hasPrefix(prefix) else { return nil }
        
        let urlString = String(string.dropFirst(prefix.count))
        
        guard let url = URL(string: urlString) else { return nil }
        
        configURL = url
    }
    
    func fetchConfiguration(completion: @escaping (Result<Data>) -> Void) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: self.configURL)                
                completion(Result(value: data))
            } catch {
                completion(Result(error: RPCConnectQRCodeError.btcPayExpired))
            }
        }
    }
}
