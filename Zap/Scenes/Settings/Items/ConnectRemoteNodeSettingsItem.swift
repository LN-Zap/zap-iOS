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
        // TODO: refactor to coordinator pattern
//        let connectRemoteNodeViewController = UIStoryboard.instantiateConnectRemoteNodeViewController()
//        fromViewController.navigationController?.pushViewController(connectRemoteNodeViewController, animated: true)
    }
}

final class RemoveRemoteNodeSettingsItem: SettingsItem {
    let title = "Remove Remote Node & Pin"
    
    func didSelectItem(from fromViewController: UIViewController) {
        RemoteNodeConfiguration.delete()
        AuthenticationViewModel.shared.resetPin()
        fatalError("Crash to restart.")
    }
}
