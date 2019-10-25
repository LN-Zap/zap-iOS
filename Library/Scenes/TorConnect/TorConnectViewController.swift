//
//  Library
//
//  Created by 0 on 24.10.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class TorConnectViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var progressLabel: UILabel!
    
    static func instantiate() -> TorConnectViewController {
        let viewController = StoryboardScene.TorConnect.torConnectViewController.instantiate()
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background
        
        titleLabel.text = "Bootstrapping Tor"
        progressLabel.text = "0%"
        
        Style.Label.headline.apply(to: titleLabel)
        Style.Label.subHeadline.apply(to: progressLabel)
    }
    
    func update(progress: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.progressLabel.text = "\(progress)%"
        }
    }
}
