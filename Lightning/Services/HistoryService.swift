//
//  Lightning
//
//  Created by Otto Suess on 18.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

public final class HistoryService {
    private let api: LightningApiProtocol
    private let channelService: ChannelService

    init(api: LightningApiProtocol, channelService: ChannelService) {
        self.api = api
        self.channelService = channelService
    }
}
