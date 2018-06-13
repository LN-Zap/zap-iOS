//
//  Zap
//
//  Created by Otto Suess on 12.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func closeChannelAlertController(channel: Channel, nodeAlias: String, closeAction: @escaping () -> Void) -> UIAlertController {
        let title: String
        let message: String
        
        if channel.state == .active {
            title = "Close Channel"
            message = "Do you really want to close the channel with node \(nodeAlias)?"
        } else {
            title = "Force Close Channel"
            message = "\(nodeAlias) is offline, are you sure you want to force close this channel? You’d have to wait for \(channel.csvDelay) blocks for your funds?"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let closeAlertAction = UIAlertAction(title: "Close", style: .destructive) { _ in
            closeAction()
        }
        alertController.addAction(cancelAlertAction)
        alertController.addAction(closeAlertAction)
        
        return alertController
    }
}
