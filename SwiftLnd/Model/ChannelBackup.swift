//
//  SwiftLnd
//
//  Created by 0 on 12.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public struct ChannelBackup {
    public let data: Data

    public init(data: Data) {
        self.data = data
    }
}

extension ChannelBackup {
    init(chanBackupSnapshot: Lnrpc_ChanBackupSnapshot) {
        data = chanBackupSnapshot.multiChanBackup.multiChanBackup
    }
}
