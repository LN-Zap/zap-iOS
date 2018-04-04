//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class SettingsViewController: GroupedTableViewController {
    init() {
        let sections: [Section<SettingsItem>] = [
            Section(title: "scene.settings.title".localized, rows: [
                CurrencySelectionSettingsItem(),
                BitcoinUnitSelectionSettingsItem()
            ]),
            Section(title: "scene.settings.section.security".localized, rows: [
                UpdatePinSettingsItem(),
                TouchIDSettingItem(),
                PaperKeySettingsItem()
            ]),
            Section(title: "scene.settings.section.wallet".localized, rows: [
                LockWalletSettingsItem()
            ])
        ]
        
        super.init(sections: sections)
        
        title = "scene.settings.title".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeButtonTapped))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
