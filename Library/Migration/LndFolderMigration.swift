//
//  Library
//
//  Created by 0 on 18.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger

/// Rename 'lnd-bitcoin-testnet' folder to 'lnd'.
final class LndFolderMigration: Migration {
    func run() {
        let fileManager = FileManager.default

        guard let applicationSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }

        let sourcePath = applicationSupportDirectory.appendingPathComponent("lnd-bitcoin-testnet")
        let targetPath = applicationSupportDirectory.appendingPathComponent("lnd")

        do {
            try fileManager.moveItem(at: sourcePath, to: targetPath)
        } catch {
            Logger.error(error)
        }
    }
}
