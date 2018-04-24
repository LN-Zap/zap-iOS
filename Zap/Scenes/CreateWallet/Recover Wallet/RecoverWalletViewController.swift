//
//  Zap
//
//  Created by Otto Suess on 24.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class RecoverWalletViewController: UIViewController {

    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Style.label.apply(to: topLabel)
        
        textView.becomeFirstResponder()
    }
}
