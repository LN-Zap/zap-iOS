//
//  Library
//
//  Created by Otto Suess on 29.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiateTimeLockedViewController(authenticationViewModel: AuthenticationViewModel) -> TimeLockedViewController {
        let viewController = Storyboard.timeLocked.instantiate(viewController: TimeLockedViewController.self)
        viewController.authenticationViewModel = authenticationViewModel
        return viewController
    }
}

class TimeLockedViewController: UIViewController {
    fileprivate var authenticationViewModel: AuthenticationViewModel?

    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var countdownLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.seaBlue

        Style.Label.body.apply(to: descriptionLabel)
        Style.Label.headline.apply(to: countdownLabel)
        
        descriptionLabel.text = "Your wallet is locked.\nYou have to wait until you can enter your pin again."
        
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
                    self?.countdownLabel.text = formattedDuration
                }
            }
            timer.fire()
        }
        
        authenticationViewModel?.timeLockStore.whenUnlocked {
            self.authenticationViewModel?.state = .locked
        }
    }
}
