//
//  Library
//
//  Created by 0 on 15.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning
import Logger
import SwiftLnd

enum StaticChannelBackupError: String, Error, Codable {
    case iCloudDisabled
    case iCloudBackupFailed
    case localBackupFailed
    case lndError
}

protocol BackupService {
    func save(data: Data, nodePubKey: String, fileName: String, completion: @escaping (Result<Success, StaticChannelBackupError>) -> Void)
}

extension BackupService {
    static var key: String {
        return String(describing: self).components(separatedBy: ".").last ?? "unknown"
    }
}
