//
//  Zap
//
//  Created by Otto Suess on 09.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Lightning
import ReactiveKit
import SwiftLnd
import UIKit

protocol DisconnectWalletDelegate: class {
    func disconnect()
    func reconnect(walletConfiguration: WalletConfiguration?)
}

final class SyncViewController: UIViewController {
    @IBOutlet private weak var gradientView: GradientView!
    @IBOutlet private weak var gradientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var syncLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var disconnectBarButton: UIBarButtonItem!
    
    private var lightningService: LightningService?
    private weak var delegate: DisconnectWalletDelegate?

    private var syncPercentageEstimator: SyncPercentageEstimator?
    
    static func instantiate(with lightningService: LightningService, delegate: DisconnectWalletDelegate) -> SyncViewController {
        let syncViewController = StoryboardScene.Sync.syncViewController.instantiate()
        syncViewController.lightningService = lightningService
        syncViewController.delegate = delegate
        return syncViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Zap.background
        
        gradientView.direction = .diagonal
        Style.Label.custom().apply(to: syncLabel, dateLabel, descriptionLabel)
        syncLabel.font = syncLabel.font.withSize(24)
        descriptionLabel.font = descriptionLabel.font.withSize(16)
        dateLabel.font = dateLabel.font.withSize(12)
        syncLabel.textColor = .white
        descriptionLabel.textColor = .white
        dateLabel.textColor = .white
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)

        descriptionLabel.text = L10n.Scene.Sync.descriptionLabel
        disconnectBarButton.title = L10n.Scene.Sync.disconnectBarButton
        
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setIdleTimer(disabled: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        setIdleTimer(disabled: false)
    }
    
    private func setIdleTimer(disabled: Bool) {
        #if !REMOTEONLY
        if let connection = lightningService?.connection,
            case .local = connection {
            UIApplication.shared.isIdleTimerDisabled = disabled
        }
        #endif
    }
    
    private func setupBindings() {
        guard let lightningService = lightningService else { fatalError("viewModel not set.") }

        let percentSignal = combineLatest(lightningService.infoService.blockHeight, lightningService.infoService.bestHeaderDate, lightningService.infoService.blockChainHeight) { [weak self] lndBlockHeigh, lndHeaderDate, maxBlockHeight -> Double in
            guard
                let lndBlockHeigh = lndBlockHeigh,
                let lndHeaderDate = lndHeaderDate,
                let maxBlockHeight = maxBlockHeight
                else { return 0 }
            
            if self?.syncPercentageEstimator == nil {
                self?.syncPercentageEstimator = SyncPercentageEstimator(initialLndBlockHeight: lndBlockHeigh, initialHeaderDate: lndHeaderDate)
            }
            
            let percentage = self?.syncPercentageEstimator?.percentage(lndBlockHeight: lndBlockHeigh, lndHeaderDate: lndHeaderDate, maxBlockHeight: maxBlockHeight) ?? 0
            
            guard percentage != Double.nan && percentage != Double.infinity else {
                return 1
            }
            
            return percentage
        }
        
        percentSignal
            .map { "\(Int($0 * 100))%" }
            .bind(to: syncLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        percentSignal
            .map { CGFloat($0) * UIScreen.main.bounds.height }
            .observeOn(DispatchQueue.main)
            .observeNext { [weak self] in
                self?.updateGradientView(for: $0)
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
    
    func updateGradientView(for height: CGFloat) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.99, animations: { [weak self] in
            guard let self = self else { return }
            self.gradientViewHeightConstraint.constant = height
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction private func disconnectNode(_ sender: Any) {
        let alertController = UIAlertController(title: L10n.Scene.Sync.DisconnectAlert.title, message: L10n.Scene.Sync.DisconnectAlert.message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: L10n.Scene.Sync.DisconnectAlert.destructiveAction, style: .destructive, handler: { [weak self] _ in
            self?.delegate?.disconnect()
        }))
        alertController.addAction(UIAlertAction(title: L10n.Scene.Sync.DisconnectAlert.cancelAction, style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}
