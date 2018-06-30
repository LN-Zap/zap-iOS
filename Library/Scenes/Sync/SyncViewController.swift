//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
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
    
    private var initialHeight: Int?
    
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
        
        descriptionLabel.text = "scene.sync.description_label".localized
        
        guard let lightningService = lightningService else { fatalError("viewModel not set.") }
        
        let percentSignal = combineLatest(lightningService.infoService.blockHeight, lightningService.infoService.blockChainHeight) { [weak self] syncedBlockHeigh, maxBlockHeight -> Double in
            if self?.initialHeight == nil {
                self?.initialHeight = syncedBlockHeigh
            }
            
            guard
                let maxBlockHeight = maxBlockHeight,
                let initialHeight = self?.initialHeight,
                maxBlockHeight - initialHeight > 0
                else { return 0 }
            
            return Double(syncedBlockHeigh - initialHeight) / Double(maxBlockHeight - initialHeight)
        }
        
        percentSignal
            .map { "\(Int($0 * 100))%" }
            .bind(to: syncLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        percentSignal
            .map { CGFloat($0) * UIScreen.main.bounds.height }
            .observeOn(DispatchQueue.main)
            .observeNext(with: updateGradientView)
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
    
    func updateGradientView(for height: CGFloat) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.99, animations: { [weak self] in
            self?.gradientViewHeightConstraint.constant = height
            self?.view.layoutIfNeeded()
        })
    }
}
