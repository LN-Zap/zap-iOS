//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

final class ConnectRemoteNodeSettingsItem: SubtitleSettingsItem {
    var subtitle: Signal<String?, NoError>
    
    let title = "Connect Remote Node"
    
    init() {
        let isRemoteNode = Observable(false)
        subtitle = isRemoteNode
            .map { $0 ? "connected" : "not connected" }
    }
    
    func didSelectItem(from fromViewController: UIViewController) {
        let connectRemoteNodeViewController = Storyboard.connectRemoteNode.initial(viewController: ConnectRemoteNodeViewController.self)
        fromViewController.navigationController?.pushViewController(connectRemoteNodeViewController, animated: true)
    }
}
