//
//  Library
//
//  Created by Otto Suess on 19.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class UpdateAddressViewController: UITableViewController {
    @IBOutlet private weak var addressCell: UITableViewCell!
    @IBOutlet private weak var addressTextField: UITextField!
    
    fileprivate var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    
    static func instantiate(connectRemoteNodeViewModel: ConnectRemoteNodeViewModel) -> UpdateAddressViewController {
        let viewController = StoryboardScene.ConnectRemoteNode.updateAddressViewController.instantiate()
        viewController.connectRemoteNodeViewModel = connectRemoteNodeViewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.deepSeaBlue
        addressCell.backgroundColor = UIColor.Zap.seaBlue
        
        title = L10n.Scene.ConnectRemoteNode.EditUrl.title
        
        addressTextField.text = connectRemoteNodeViewModel?.remoteNodeConfiguration?.url.absoluteString
        addressTextField.becomeFirstResponder()

        tableView.separatorColor = UIColor.Zap.gray

        Style.textField().apply(to: addressTextField)
        addressTextField.textColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let urlString = addressTextField.text,
            let url = URL(string: urlString) {
            connectRemoteNodeViewModel?.updateUrl(url)
        }
    }
}
