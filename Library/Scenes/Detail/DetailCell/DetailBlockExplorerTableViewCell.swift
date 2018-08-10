//
//  Zap
//
//  Created by Otto Suess on 07.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class DetailBlockExplorerTableViewCell: UITableViewCell {
    struct Info {
        let title: String
        let code: String
        let type: BlockExplorer.CodeType
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailButton: UIButton!
    
    weak var delegate: DetailCellDelegate?
    
    var info: DetailBlockExplorerTableViewCell.Info? {
        didSet {
            guard let info = info else { return }
            
            titleLabel.text = info.title.appending(":")
            detailButton.setTitle(info.code, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        Style.label().apply(to: titleLabel)
        Style.button().apply(to: detailButton)
        
        titleLabel.font = DetailCellType.titleFont
        detailButton.titleLabel?.font = DetailCellType.dataFont
    }

    @IBAction private func presentBlockExplorer(_ sender: Any) {
        guard let info = info else { return }
        delegate?.presentBlockExplorer(info.code, type: info.type)
    }
    
}
