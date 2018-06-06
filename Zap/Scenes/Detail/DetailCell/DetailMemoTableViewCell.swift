//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

final class DetailMemoTableViewCell: BondTableViewCell {
    struct Info {
        let memo: Observable<String?>
        let placeholder: String
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    var onChange: ((String?) -> Void)?
    
    var info: Info? {
        didSet {
            titleLabel.text = "Memo"
            info?.memo
                .bind(to: textField.reactive.text)
                .dispose(in: onReuseBag)
            textField.placeholder = info?.placeholder
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.textField.apply(to: textField)
        Style.label.apply(to: titleLabel)
        
        textField.reactive.text
            .observeNext { [weak self] text in
                self?.onChange?(text)
            }
            .dispose(in: onReuseBag)
    }
}
