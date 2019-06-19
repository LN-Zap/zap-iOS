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

final class StaticChannelBackupService: StaticChannelBackupServiceType {
    private let backupServices: [BackupService] = [
        ICloudDriveBackupService(),
        LocalDocumentBackupService()
    ]

    func save(data: Result<Data, LndApiError>, nodePubKey: String, fileName: String) {
        switch data {
        case .success(let data):
            var errors = [StaticChannelBackupError]()
            var successfulServices = [String]()
            let startDate = Date()

            let dispatchGroup = DispatchGroup()

            for backupService in backupServices {
                dispatchGroup.enter()
                backupService.save(data: data, nodePubKey: nodePubKey, fileName: fileName) {
                    switch $0 {
                    case .success:
                        let serviceKey = type(of: backupService).key
                        successfulServices.append(serviceKey)
                    case .failure(let error):
                        errors.append(error)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                let date = successfulServices.isEmpty ? nil : startDate
                let backupResult = StaticChannelBackupResult(errors: errors, successfulServiceKeys: successfulServices, timestamp: date)
                StaticChannelBackupStateStore.update(nodePubKey: nodePubKey, data: backupResult)
                Logger.info(backupResult)
            }
        case .failure:
            let backupResult = StaticChannelBackupResult(errors: [.lndError], successfulServiceKeys: [], timestamp: nil)
            StaticChannelBackupStateStore.update(nodePubKey: nodePubKey, data: backupResult)
        }
    }
}
