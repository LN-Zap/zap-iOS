//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import SafariServices
import UIKit

extension UIStoryboard {
    static func instantiateSetupViewController(createButtonTapped: @escaping () -> Void, recoverButtonTapped: @escaping () -> Void, connectButtonTapped: @escaping () -> Void) -> UINavigationController {
        
        let navigationController = Storyboard.createWallet.initial(viewController: UINavigationController.self)
        if let setupWalletViewController = navigationController.topViewController as? SelectWalletCreationMethodViewController {
            setupWalletViewController.createButtonTapped = createButtonTapped
            setupWalletViewController.recoverButtonTapped = recoverButtonTapped
            setupWalletViewController.connectButtonTapped = connectButtonTapped
        }
        return navigationController
    }
}

final class SelectWalletCreationMethodViewController: UIViewController {
    fileprivate var createButtonTapped: (() -> Void)?
    fileprivate var recoverButtonTapped: (() -> Void)?
    fileprivate var connectButtonTapped: (() -> Void)?
    
    @IBOutlet private weak var tableView: UITableView!
    
    // swiftlint:disable:next large_tuple
    var content: [(String, String, (() -> Void))]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.select_wallet_connection.title".localized
        
        // swiftlint:disable opening_brace
        content = [
            ("scene.select_wallet_connection.create.title".localized,
             "scene.select_wallet_connection.create.message".localized,
             { [weak self] in self?.createButtonTapped?() }
            ),
            ("scene.select_wallet_connection.recover.title".localized,
             "scene.select_wallet_connection.recover.message".localized,
             { [weak self] in self?.recoverButtonTapped?() }
            ),
            ("scene.select_wallet_connection.connect.title".localized,
             "scene.select_wallet_connection.connect.message".localized,
             { [weak self] in self?.connectButtonTapped?() }
            )
        ]
        // swiftlint:enable opening_brace
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.registerCell(SelectWalletCreationMethodTableViewCell.self)
        tableView.backgroundColor = UIColor.zap.deepSeaBlue
        tableView.separatorColor = UIColor.zap.warmGrey
        
        navigationController?.navigationBar.barTintColor = UIColor.zap.deepSeaBlue
    }
}

extension SelectWalletCreationMethodViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            guard let url = URL(string: "link.help".localized) else { return }
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.preferredBarTintColor = UIColor.zap.deepSeaBlue
            safariViewController.preferredControlTintColor = UIColor.zap.lightningOrange
            present(safariViewController, animated: true, completion: nil)
        } else if let cellContent = content?[indexPath.row] {
            cellContent.2()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 114 : 76
    }
}

extension SelectWalletCreationMethodViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? content?.count ?? 0 : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: SelectWalletCreationMethodTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            if let cellContent = content?[indexPath.row] {
                cell.set(title: cellContent.0, description: cellContent.1)
            }
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "default")
            cell.backgroundColor = UIColor.zap.seaBlue
            if let label = cell.textLabel {
                Style.label().apply(to: label)
                label.font = label.font.withSize(14)
                label.text = "scene.select_wallet_connection.create.help".localized
                label.textColor = .white
            }
            return cell
        }
    }
}
