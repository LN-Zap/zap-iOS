//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import ReactiveKit

class BondTableViewCell: UITableViewCell {
    let onReuseBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuseBag.dispose()
    }
}
