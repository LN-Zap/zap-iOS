//
//  Library
//
//  Created by 0 on 13.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning
import Logger
import SwiftLnd

final class LocalDocumentBackupService: BackupService {
    func save(data: Data, nodePubKey: String, fileName: String, completion: @escaping (Result<Success, StaticChannelBackupError>) -> Void) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(.failure(.localBackupFailed))
            return
        }
        let url = documentDirectory
            .appendingPathComponent(nodePubKey)
            .appendingPathComponent(fileName)

        DispatchQueue.global().async {
            do {
                let directory = url.deletingLastPathComponent().path
                if !FileManager.default.fileExists(atPath: directory) {
                    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
                }

                try data.write(to: url, options: [.atomic])
                Logger.info("Did backup file to Documents at \(url.path)", customPrefix: "📀")
                completion(.success(Success()))
            } catch {
                Logger.error(error.localizedDescription)
                completion(.failure(.localBackupFailed))
            }
        }
    }
}
