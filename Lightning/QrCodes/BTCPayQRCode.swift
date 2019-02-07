//
//  Lightning
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

struct BTCPayQRCode {
    let configURL: URL
    
    init?(string: String) {
        let prefix = "config="
        guard string.hasPrefix(prefix) else { return nil }
        
        let urlString = String(string.dropFirst(prefix.count))
        
        guard let url = URL(string: urlString) else { return nil }
        
        configURL = url
    }
    
    func fetchConfiguration(completion: @escaping (Result<Data, RPCConnectQRCodeError>) -> Void) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: self.configURL)                
                completion(.success(data))
            } catch {
                completion(.failure(RPCConnectQRCodeError.btcPayExpired))
            }
        }
    }
}
