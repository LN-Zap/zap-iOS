//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class DetailLegendTableViewCell: UITableViewCell {
    struct Info {
        let title: String
        let data: String
        let gradient: [UIColor]
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dataLabel: UILabel!
    @IBOutlet private weak var gradientView: GradientView!
    
    var info: Info? {
        didSet {
            guard let info = info else { return }
            titleLabel.text = info.title
            dataLabel.text = info.data
            gradientView.gradient = info.gradient
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradientView.layer.cornerRadius = 5
        Style.label.apply(to: titleLabel, dataLabel)
        titleLabel.font = DetailCellType.titleFont
        dataLabel.font = DetailCellType.dataFont
    }
}
