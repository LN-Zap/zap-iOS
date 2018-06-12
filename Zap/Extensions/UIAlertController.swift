//
//  Zap
//
//  Created by Otto Suess on 12.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func closeChannelAlertController(channelName: String, closeAction: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: "Close Channel", message: "Do you really want to close channel with node \(channelName)?", preferredStyle: .actionSheet)
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let closeAlertAction = UIAlertAction(title: "Close", style: .destructive) { _ in
            closeAction()
        }
        alertController.addAction(cancelAlertAction)
        alertController.addAction(closeAlertAction)
        
        return alertController
    }
}
