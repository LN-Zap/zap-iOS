//
//  Library
//
//  Created by 0 on 13.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger

/// Move all files from the document Dir to the applicationSupport Dir
final class RootFolderMigration: Migration {
    func run() {
        let fileManager = FileManager.default

        guard
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
            let applicationSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            else { return }

        if let enumerator = fileManager.enumerator(atPath: documentDirectory.path) {
            for case let path as String in enumerator {
                let sourcePath = documentDirectory.appendingPathComponent(path)
                let targetPath = applicationSupportDirectory.appendingPathComponent(path)

                do {
                    try fileManager.createDirectory(atPath: targetPath.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                    try fileManager.moveItem(atPath: sourcePath.path, toPath: targetPath.path)
                } catch {
                    if (error as NSError).code == NSFileWriteFileExistsError {
                        try? fileManager.removeItem(at: sourcePath)
                    } else {
                        Logger.error(error)
                    }
                }
            }
        }

    }
}
