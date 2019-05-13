//
//  Library
//
//  Created by 0 on 13.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning

final class BackupServiceGroup: BackupService {
    private let backupServices: [BackupService]

    init(backupServices: [BackupService]) {
        self.backupServices = backupServices
    }

    func save(data: Data, fileId: String) {
        backupServices.forEach { $0.save(data: data, fileId: fileId) }
    }
}
