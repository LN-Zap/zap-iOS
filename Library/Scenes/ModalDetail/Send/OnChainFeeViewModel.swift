//
//  Library
//
//  Created by 0 on 23.05.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

struct FeeTier {
    let title: String
    let description: String
    let confirmationTarget: Int

    var formattedConfirmationTimeInterval: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        let timeInterval = TimeInterval((confirmationTarget + 1) * 10 * 60)
        return formatter.string(from: timeInterval) ?? ""
    }
}

final class OnChainFeeViewModel {
    let tiers: [FeeTier] = [
        FeeTier(title: L10n.Scene.Send.OnChain.Fee.fast, description: L10n.Scene.Send.OnChain.Fee.Description.fast, confirmationTarget: 0),
        FeeTier(title: L10n.Scene.Send.OnChain.Fee.medium, description: L10n.Scene.Send.OnChain.Fee.Description.medium, confirmationTarget: 6 * 6),
        FeeTier(title: L10n.Scene.Send.OnChain.Fee.slow, description: L10n.Scene.Send.OnChain.Fee.Description.slow, confirmationTarget: 6 * 24)
    ]

    var titles: [String] {
        return tiers.map { $0.title }
    }
}
