//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateLoadingViewController(message: LoadingViewController.Message) -> LoadingViewController {
        let viewController = Storyboard.loading.initial(viewController: LoadingViewController.self)
        viewController.message = message
        return viewController
    }
}

final class LoadingViewController: UIViewController {
    enum Message {
        case none
        case noInternet
    }
    
    @IBOutlet private weak var infoLabel: UILabel!
    
    fileprivate var message = Message.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.zap.seaBlue
        
        Style.Label.custom().apply(to: infoLabel)
        infoLabel.textColor = .white
        
        switch message {
        case .none:
            infoLabel.text = nil
        case .noInternet:
            infoLabel.text = LndApiError.noInternet.localizedDescription
        }
    }
}
