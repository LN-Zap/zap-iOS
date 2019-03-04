//
//  Library
//
//  Created by Otto Suess on 10.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class BlockExplorerSelectionSettingsItem: DetailDisclosureSettingsItem, SubtitleSettingsItem {
    var subtitle = Settings.shared.blockExplorer.map { Optional($0.localized) }

    var title = L10n.Scene.Settings.Item.blockExplorer

    func didSelectItem(from fromViewController: UIViewController) {

        let items: [SettingsItem] = BlockExplorer.allCases.map { BlockExplorerSettingsItem(blockExplorer: $0) }
        let section = Section(title: nil, rows: items)

        let viewController = GroupedTableViewController(sections: [section])
        viewController.title = title
        viewController.navigationItem.largeTitleDisplayMode = .never

        fromViewController.navigationController?.show(viewController, sender: nil)
    }
}

final class BlockExplorerSettingsItem: NSObject, SelectableSettingsItem {
    var isSelectedOption = Observable(false)

    let title: String
    private let blockExplorer: BlockExplorer

    init(blockExplorer: BlockExplorer) {
        self.blockExplorer = blockExplorer
        title = blockExplorer.localized
        super.init()

        Settings.shared.blockExplorer
            .observeNext { [isSelectedOption] currentBlockExplorer in
                isSelectedOption.value = currentBlockExplorer == blockExplorer
            }
            .dispose(in: reactive.bag)
    }

    func didSelectItem(from fromViewController: UIViewController) {
        Settings.shared.blockExplorer.value = blockExplorer
    }
}
