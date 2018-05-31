//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    enum Message {
        case none
        case noInternet
    }
    
    @IBOutlet private weak var infoLabel: UILabel!
    
    var state = Message.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.label.apply(to: infoLabel)
        infoLabel.textColor = .white
        
        switch state {
        case .none:
            infoLabel.text = nil
        case .noInternet:
            infoLabel.text = LndError.noInternet.localizedDescription
        }
    }
}
