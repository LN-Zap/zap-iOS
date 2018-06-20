//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import ReactiveKit
import UIKit

extension UIStoryboard {
    static func instantiateSyncViewController(with lightningService: LightningService) -> SyncViewController {
        let syncViewController = Storyboard.sync.initial(viewController: SyncViewController.self)
        syncViewController.lightningService = lightningService
        return syncViewController
    }
}

final class SyncViewController: UIViewController {
    @IBOutlet private weak var gradientView: GradientView!
    @IBOutlet private weak var gradientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var syncLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    fileprivate var lightningService: LightningService?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gradientView.direction = .diagonal
        Style.label.apply(to: syncLabel, dateLabel, descriptionLabel)
        syncLabel.font = syncLabel.font.withSize(24)
        descriptionLabel.font = descriptionLabel.font.withSize(16)
        dateLabel.font = dateLabel.font.withSize(12)
        syncLabel.textColor = .white
        descriptionLabel.textColor = .white
        dateLabel.textColor = .white
        
        descriptionLabel.text = "Syncing to blockchain…"
        
        guard let lightningService = lightningService else { fatalError("viewModel not set.") }
        
        let percentSignal = combineLatest(lightningService.infoService.blockHeight, lightningService.infoService.blockChainHeight) { blockHeigh, maxBlockHeight -> Double in
            guard let maxBlockHeight = maxBlockHeight else { return 0 }
            return Double(blockHeigh) / Double(maxBlockHeight)
        }
        
        percentSignal
            .map { "\(Int($0 * 100))%" }
            .bind(to: syncLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        percentSignal
            .map { CGFloat($0) * UIScreen.main.bounds.height }
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                self?.gradientViewHeightConstraint.constant = $0
            }
            .dispose(in: reactive.bag)
        
        lightningService.infoService.bestHeaderDate
            .map {
                if let date = $0 {
                    return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
                } else {
                    return ""
                }
            }
            .bind(to: dateLabel.reactive.text)
            .dispose(in: reactive.bag)
    }
}
