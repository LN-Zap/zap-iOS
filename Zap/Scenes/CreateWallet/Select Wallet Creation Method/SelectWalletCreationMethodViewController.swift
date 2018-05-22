//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SelectWalletCreationMethodViewController: UIViewController {
    
    var viewModel: ViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    
    // swiftlint:disable:next large_tuple
    let content: [(String, String, (() -> UIViewController))] = [
        ("Create", "new wallet", {
            Storyboard.createWallet.instantiate(viewController: MnemonicViewController.self)
        }),
        ("Recover", "existing wallet", {
            Storyboard.createWallet.instantiate(viewController: RecoverWalletViewController.self)
        }),
        ("Connect", "remote node", {
            Storyboard.connectRemoteNode.initial()
        })
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.darkBackground

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 140
        tableView.isScrollEnabled = false
        tableView.registerCell(SelectWalletCreationMethodTableViewCell.self)
        tableView.backgroundColor = Color.darkBackground
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let viewModel = viewModel,
            let destination = segue.destination as? MnemonicViewController
            else { return }
        destination.mnemonicViewModel = MnemonicViewModel(viewModel: viewModel)
    }
}

extension SelectWalletCreationMethodViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellContent = content[indexPath.row]
        let viewController = cellContent.2()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SelectWalletCreationMethodViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectWalletCreationMethodTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        let cellContent = content[indexPath.row]
        cell.set(title: cellContent.0, description: cellContent.1)
        return cell
    }
}
