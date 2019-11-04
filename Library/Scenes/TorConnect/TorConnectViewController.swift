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
    
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = Locale.current
        return numberFormatter
    }()
    
    static func instantiate() -> TorConnectViewController {
        let viewController = StoryboardScene.TorConnect.torConnectViewController.instantiate()
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background
        
        titleLabel.text = L10n.Scene.Tor.headline
        progressLabel.text = localizedString(percent: 0)
        
        Style.Label.headline.apply(to: titleLabel)
        Style.Label.subHeadline.apply(to: progressLabel)
    }
    
    private func localizedString(percent: Double) -> String? {
        return numberFormatter.string(from: percent / 100 as NSNumber)
    }
    
    func update(progress: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.progressLabel.text = self?.localizedString(percent: Double(progress))
        }
    }
}
