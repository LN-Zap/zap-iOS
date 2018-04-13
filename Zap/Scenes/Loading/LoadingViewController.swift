//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet private weak var infoLabel: UILabel!
    
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.label.apply(to: infoLabel)
        infoLabel.textColor = .white
        infoLabel.text = message
    }
}
