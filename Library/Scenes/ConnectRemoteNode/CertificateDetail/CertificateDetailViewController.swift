//
//  Library
//
//  Created by Otto Suess on 19.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIStoryboard {
    static func instantiateCertificateDetailViewController(connectRemoteNodeViewModel: ConnectRemoteNodeViewModel) -> CertificateDetailViewController {
        let viewController = StoryboardScene.ConnectRemoteNode.certificateDetailViewController.instantiate()
        viewController.connectRemoteNodeViewModel = connectRemoteNodeViewModel
        return viewController
    }
}

final class CertificateDetailViewController: UITableViewController {
    fileprivate var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Scene.ConnectRemoteNode.CertificateDetail.certificateTitle
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.Zap.deepSeaBlue
        tableView.separatorColor = UIColor.Zap.gray
        tableView.estimatedRowHeight = 300
        tableView.registerCell(CertificateDetailCell.self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return L10n.Scene.ConnectRemoteNode.CertificateDetail.certificateTitle
        } else {
            return L10n.Scene.ConnectRemoteNode.CertificateDetail.macaroonTitle
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CertificateDetailCell = tableView.dequeueCellForIndexPath(indexPath)
        if indexPath.section == 0 {
            cell.descriptionText = connectRemoteNodeViewModel?.remoteNodeConfiguration?.certificate
        } else {
            cell.descriptionText = connectRemoteNodeViewModel?.remoteNodeConfiguration?.macaroon.hexadecimalString
        }
        cell.contentView.backgroundColor = UIColor.Zap.seaBlue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.textLabel?.text = view.textLabel?.text?.capitalized
    }
}
