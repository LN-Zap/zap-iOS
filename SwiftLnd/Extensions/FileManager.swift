//
//  SwiftLnd
//
//  Created by Otto Suess on 06.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import SwiftBTC

public extension FileManager {
    func channelBackupDirectory(for nodePubKey: String) -> URL? {
        guard let documentDirectory = urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let url = documentDirectory.appendingPathComponent(nodePubKey, isDirectory: true)
        return createAndReturn(url: url)
    }

    var walletDirectory: URL? {
        guard let applicationSupportDirectory = urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        let url = applicationSupportDirectory.appendingPathComponent("lnd", isDirectory: true)
        return createAndReturn(url: url)
    }

    private func walletDatabase(for network: Network) -> URL? {
        return FileManager.default.walletDirectory?.appendingPathComponent("/data/chain/bitcoin/\(network.rawValue)/wallet.db")
    }

    var hasLocalWallet: Network? {
        let fileManager = FileManager.default

        if let mainnetURL = fileManager.walletDatabase(for: .mainnet), fileManager.fileExists(atPath: mainnetURL.path) {
            return .mainnet
        } else if let testnetURL = fileManager.walletDatabase(for: .testnet), fileManager.fileExists(atPath: testnetURL.path) {
            return .testnet
        }

        return nil
    }

    private func createAndReturn(url: URL) -> URL? {
        do {
            try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Logger.error(error)
            return nil
        }

        return url
    }
}
