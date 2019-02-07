//
//  Library
//
//  Created by Otto Suess on 29.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class TimeLockedViewController: UIViewController {
    fileprivate var authenticationViewModel: AuthenticationViewModel?

    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var countdownLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    static func instantiate(authenticationViewModel: AuthenticationViewModel) -> TimeLockedViewController {
        let viewController = StoryboardScene.TimeLocked.timeLockedViewController.instantiate()
        viewController.authenticationViewModel = authenticationViewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.background

        Style.Label.headline.apply(to: headlineLabel)
        Style.Label.body.apply(to: descriptionLabel)
        Style.Label.title.apply(to: countdownLabel)
        
        headlineLabel.text = L10n.Scene.TimeLock.headline
        descriptionLabel.text = L10n.Scene.TimeLock.description
        
        if let timeLockEnd = authenticationViewModel?.timeLockStore.timeLockEnd {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                let duration = timeLockEnd.timeIntervalSince(Date())
                if duration <= 0 {
                    timer.invalidate()
                }
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits =  [.year, .month, .day, .hour, .minute, .second]
                formatter.unitsStyle = .full
                formatter.maximumUnitCount = 3

                if let formattedDuration = formatter.string(from: duration) {
                    self?.countdownLabel.text = formattedDuration.replacingOccurrences(of: ", ", with: ",\n")
                }
            }
            timer.fire()
        }
        
        authenticationViewModel?.timeLockStore.whenUnlocked {
            self.authenticationViewModel?.state = .locked
        }
    }
}
