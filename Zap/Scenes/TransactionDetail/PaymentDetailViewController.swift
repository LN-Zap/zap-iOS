//
//  Zap
//
//  Created by Otto Suess on 06.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class PaymentDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment Detail"
        
        view.backgroundColor = .red
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
