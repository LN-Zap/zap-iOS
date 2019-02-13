//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import SafariServices
import UIKit

final class SelectWalletCreationMethodViewController: UIViewController {
    private var createButtonTapped: (() -> Void)?
    private var recoverButtonTapped: (() -> Void)?
    private var connectButtonTapped: (() -> Void)?
    
    @IBOutlet private weak var tableView: UITableView!
    
    // swiftlint:disable:next large_tuple
    var content: [(String, String, (() -> Void))]?
    
    static func instantiate(createButtonTapped: @escaping () -> Void, recoverButtonTapped: @escaping () -> Void, connectButtonTapped: @escaping () -> Void) -> SelectWalletCreationMethodViewController {
        let setupWalletViewController = StoryboardScene.CreateWallet.selectWalletCreationMethodViewController.instantiate()
        setupWalletViewController.createButtonTapped = createButtonTapped
        setupWalletViewController.recoverButtonTapped = recoverButtonTapped
        setupWalletViewController.connectButtonTapped = connectButtonTapped
        return setupWalletViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Scene.SelectWalletConnection.title
        
        // swiftlint:disable opening_brace
        content = [
            (L10n.Scene.SelectWalletConnection.Create.title,
             L10n.Scene.SelectWalletConnection.Create.message,
             { [weak self] in self?.createButtonTapped?() }
            ),
            (L10n.Scene.SelectWalletConnection.Recover.title,
             L10n.Scene.SelectWalletConnection.Recover.message,
             { [weak self] in self?.recoverButtonTapped?() }
            ),
            (L10n.Scene.SelectWalletConnection.Connect.title,
             L10n.Scene.SelectWalletConnection.Connect.message,
             { [weak self] in self?.connectButtonTapped?() }
            )
        ]
        // swiftlint:enable opening_brace
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.registerCell(SelectWalletCreationMethodTableViewCell.self)
        tableView.backgroundColor = UIColor.Zap.deepSeaBlue
        tableView.separatorColor = UIColor.Zap.gray
        
        navigationController?.navigationBar.barTintColor = UIColor.Zap.deepSeaBlue
    }
}

extension SelectWalletCreationMethodViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            guard let url = URL(string: L10n.Link.help) else { return }
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.preferredBarTintColor = UIColor.Zap.deepSeaBlue
            safariViewController.preferredControlTintColor = UIColor.Zap.lightningOrange
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
            cell.backgroundColor = UIColor.Zap.seaBlue
            if let label = cell.textLabel {
                Style.Label.custom().apply(to: label)
                label.font = label.font.withSize(14)
                label.text = L10n.Scene.SelectWalletConnection.Create.help
                label.textColor = .white
            }
            return cell
        }
    }
}
