//
//  Zap
//
//  Created by Otto Suess on 12.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

extension UIAlertController {
    static func closeChannelAlertController(channelViewModel: ChannelViewModel, closeAction: @escaping () -> Void) -> UIAlertController {
        let title: String
        let message: String
        let closeButtonTitle: String

        let channel = channelViewModel.channel

        if channel.state == .active {
            title = L10n.Scene.Channels.Close.title
            message = L10n.Scene.Channels.Close.message(channelViewModel.name.value)
            closeButtonTitle = L10n.Scene.Channels.Alert.close

        } else {
            title = L10n.Scene.Channels.ForceClose.title
            closeButtonTitle = L10n.Scene.Channels.Alert.forceClose

            let formatter = DateComponentsFormatter()
            formatter.allowedUnits =  [.year, .month, .day, .hour, .minute]
            formatter.unitsStyle = .full
            formatter.maximumUnitCount = 2

            let blockTime: TimeInterval = 10 * 60
            let timeUntilClose = formatter.string(from: TimeInterval(channel.csvDelay) * blockTime) ?? ""

            message = L10n.Scene.Channels.ForceClose.message(channelViewModel.name.value, timeUntilClose)
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAlertAction = UIAlertAction(title: L10n.Generic.cancel, style: .cancel, handler: nil)

        let closeAlertAction = UIAlertAction(title: closeButtonTitle, style: .destructive) { _ in
            closeAction()
        }
        alertController.addAction(cancelAlertAction)
        alertController.addAction(closeAlertAction)

        return alertController
    }
}
