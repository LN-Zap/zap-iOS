//
//  Zap
//
//  Created by Otto Suess on 24.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

protocol SettingsItem {
    var title: String { get }

    func didSelectItem(from fromViewController: UIViewController)
}

protocol DetailDisclosureSettingsItem: SettingsItem {}

protocol SubtitleSettingsItem: SettingsItem {
    var subtitle: Signal<String?, Never> { get }
}

protocol SelectableSettingsItem: SettingsItem {
    var isSelectedOption: Observable<Bool> { get }
}

protocol ToggleSettingsItem: SettingsItem {
    var isToggled: Observable<Bool> { get }
}
