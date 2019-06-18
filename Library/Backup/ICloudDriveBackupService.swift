//
//  Library
//
//  Created by 0 on 08.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning
import Logger

final class ICloudDriveBackupService: BackupService {
    private var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }

    init() {
        setupICloud()
    }

    private func setupICloud() {
        DispatchQueue.global().async {
            // check for container existence
            guard
                let url = self.containerUrl,
                !FileManager.default.fileExists(atPath: url.path, isDirectory: nil)
                else { return }

            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Logger.error(error.localizedDescription)
            }
        }
    }

    func save(data: Data, nodePubKey: String, fileName: String) {
        DispatchQueue.global().async { [weak self] in
            guard let url = self?.containerUrl?
                .appendingPathComponent(nodePubKey)
                .appendingPathComponent(fileName)
                else { return }

            do {
                let directory = url.deletingLastPathComponent().path
                if !FileManager.default.fileExists(atPath: directory) {
                    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                }

                try data.write(to: url, options: [.atomic])
                self?.didBackup(nodePubKey: nodePubKey)
                Logger.info("Did backup file to iCloud at \(url.path)", customPrefix: "📀")
            } catch {
                Logger.error(error.localizedDescription)
            }
        }
    }
}
