//
//  Library
//
//  Created by 0 on 13.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning
import Logger

final class LocalDocumentBackupService: BackupService, BackupLogger {
    func save(data: Data, fileId: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = documentDirectory.appendingPathComponent(fileId)

        DispatchQueue.global().async { [weak self] in
            do {
                let directory = url.deletingLastPathComponent().path
                if !FileManager.default.fileExists(atPath: directory) {
                    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                }

                try data.write(to: url, options: [.atomic])
                self?.didBackup()
                Logger.info("Did backup file to Documents at \(url.path)", customPrefix: "📀")
            } catch {
                Logger.error(error.localizedDescription)
            }
        }
    }
}
