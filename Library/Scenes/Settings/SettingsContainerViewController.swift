//
//  Zap
//
//  Created by Otto Suess on 04.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateSettingsContainerViewController(with lightningService: LightningService) -> UINavigationController {
        let viewController = Storyboard.settings.initial(viewController: UINavigationController.self)
        
        if let settingsContainerViewController = viewController.topViewController as? SettingsContainerViewController {
            settingsContainerViewController.lightningService = lightningService
        }
        
        return viewController
    }
}

final class SettingsContainerViewController: UIViewController, ContainerViewController {
    @IBOutlet private weak var primaryCurrencyLabel: UILabel!
    @IBOutlet private weak var secondaryCurrencyLabel: UILabel!
    @IBOutlet private weak var exchangeRateLabel: UILabel!
    
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?

    var lightningService: LightningService?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.zap.charcoalGrey
        
        lightningService?.balanceService.total
            .bind(to: primaryCurrencyLabel.reactive.text, currency: Settings.shared.primaryCurrency)
            .dispose(in: reactive.bag)
        
        lightningService?.balanceService.total
            .bind(to: secondaryCurrencyLabel.reactive.text, currency: Settings.shared.secondaryCurrency)
            .dispose(in: reactive.bag)
        
        Style.label.apply(to: primaryCurrencyLabel, secondaryCurrencyLabel, exchangeRateLabel)
        primaryCurrencyLabel.textColor = .white
        primaryCurrencyLabel.font = primaryCurrencyLabel.font.withSize(30)
        secondaryCurrencyLabel.textColor = .gray
        exchangeRateLabel.textColor = .gray

        let viewController = SettingsViewController()
        setContainerContent(viewController)
        
        title = "scene.settings.title".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateExchangeRateLabel()
    }
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateExchangeRateLabel() {
        let bitcoin = Bitcoin(unit: .bitcoin)
        let satoshis: Satoshi = 100_000_000
        
        if let bitcoin = bitcoin.format(satoshis: satoshis),
            let fiat = Settings.shared.fiatCurrency.value.format(satoshis: satoshis) {
            exchangeRateLabel.text = "\(bitcoin) = \(fiat)"
        }
    }
}
