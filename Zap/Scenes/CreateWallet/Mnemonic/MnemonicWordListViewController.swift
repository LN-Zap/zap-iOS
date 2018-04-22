//
//  Zap
//
//  Created by Otto Suess on 16.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class MnemonicWordListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    var mnemonicPageViewModel: [MnemonicWord]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 58
        tableView.backgroundColor = .clear
        view.backgroundColor = .clear
    }
}

extension MnemonicWordListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mnemonicPageViewModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MnemonicWordTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
        
        let word = mnemonicPageViewModel?[indexPath.row]
        cell.index = word?.index
        cell.word = word?.word
        
        return cell
    }
}
