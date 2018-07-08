//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Lightning
import UIKit

final class DetailMemoTableViewCell: BondTableViewCell {
    struct Info {
        let memo: Observable<TransactionAnnotation>
        let placeholder: String
        let onChange: ((String?) -> Void)?
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    var info: Info? {
        didSet {
            titleLabel.text = "scene.transaction_detail.memo_label".localized.appending(":")
            textField.text = info?.memo.value.customMemo
            textField.placeholder = info?.placeholder
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.textField.apply(to: textField)
        Style.label.apply(to: titleLabel)
        titleLabel.font = DetailCellType.titleFont
        textField.font = DetailCellType.dataFont
        
        textField.reactive.text
            .observeNext { [weak self] text in
                self?.info?.onChange?(text)
            }
            .dispose(in: onReuseBag)
    }
}
