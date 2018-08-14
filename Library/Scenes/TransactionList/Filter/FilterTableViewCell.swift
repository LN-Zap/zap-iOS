//
//  Library
//
//  Created by Otto Suess on 04.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol FilterTableViewCellDelegate: class {
    func setFilterSetting(_ filterSetting: FilterSetting, active: Bool)
}

final class FilterTableViewCell: UITableViewCell {
    @IBOutlet private weak var filterSettingLabel: UILabel!
    @IBOutlet private weak var filterSwitch: UISwitch!
    
    private var filterSetting: FilterSetting?
    
    weak var delegate: FilterTableViewCellDelegate?
    
    func set(filterSetting: FilterSetting, from filterSettings: FilterSettings) {
        self.filterSetting = filterSetting

        filterSettingLabel.text = filterSetting.localized
        filterSwitch.isOn = filterSetting.isActive(in: filterSettings)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Style.Label.custom(color: UIColor.zap.white).apply(to: filterSettingLabel)
        
        filterSwitch.onTintColor = UIColor.zap.lightningOrange
        backgroundColor = UIColor.zap.seaBlue
    }
    
    @IBAction private func toggleSettingsItem(_ sender: UISwitch) {
        guard let filterSetting = filterSetting else { return }
        delegate?.setFilterSetting(filterSetting, active: sender.isOn)
    }
}
