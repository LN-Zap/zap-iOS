//
//  SwiftLnd
//
//  Created by 0 on 08.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import SwiftBTC

enum BackupDisabler {
    private static let neutrinoFiles = [
        "reg_filter_headers.bin",
        "block_headers.bin",
        "neutrino.db"
    ]
    
    static func disableNeutrinoBackup(walletId: WalletId, network: Network) {
        var walletDirectory = FileManager.default.walletDirectory(for: walletId)
        walletDirectory?.appendPathComponent(dataPath(for: network), isDirectory: true)

        for file in neutrinoFiles {
            guard let fileURL = walletDirectory?.appendingPathComponent(file, isDirectory: false) else { continue }
            addSkipBackupAttributeToItem(at: fileURL)
        }
    }

    private static func dataPath(for network: Network) -> String {
        return "data/chain/bitcoin/\(network)"
    }

    private static func addSkipBackupAttributeToItem(at url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            Logger.warn("Error excluding \(url.path) from backup. (File not found)")
            return
        }

        do {
            var url = url
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try url.setResourceValues(resourceValues)
            Logger.info("Did disable backup for \(url.lastPathComponent)")
        } catch let error as NSError {
            Logger.error("Error excluding \(url.lastPathComponent) from backup \(error)")
        }
    }
}
