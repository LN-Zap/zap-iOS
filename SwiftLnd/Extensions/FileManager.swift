//
//  SwiftLnd
//
//  Created by Otto Suess on 06.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public typealias WalletId = String

public extension FileManager {
    func walletDirectory(for walletId: WalletId) -> URL? {
        guard let documentDirectory = urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let walletIdFolder = "lnd-" + walletId
        
        let url = documentDirectory.appendingPathComponent(walletIdFolder, isDirectory: true)
        
        do {
            try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("🤮 \(error)")
            return nil
        }
        
        return url
    }
}
