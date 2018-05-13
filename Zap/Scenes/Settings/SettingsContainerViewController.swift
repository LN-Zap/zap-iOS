//
//  Zap
//
//  Created by Otto Suess on 04.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SettingsContainerViewController: UIViewController, ContainerViewController {
    @IBOutlet private weak var headerBackground: UIView!
    @IBOutlet private weak var primaryCurrencyLabel: UILabel!
    @IBOutlet private weak var secondaryCurrencyLabel: UILabel!
    
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?

    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Color.darkBackground
        
        headerBackground.backgroundColor = Color.darkBackground
        
        viewModel?.totalBalance
            .bind(to: primaryCurrencyLabel.reactive.text, currency: Settings.primaryCurrency)
            .dispose(in: reactive.bag)
        
        viewModel?.totalBalance
            .bind(to: secondaryCurrencyLabel.reactive.text, currency: Settings.secondaryCurrency)
            .dispose(in: reactive.bag)
        
        Style.label.apply(to: primaryCurrencyLabel, secondaryCurrencyLabel)
        primaryCurrencyLabel.textColor = .white
        primaryCurrencyLabel.font = primaryCurrencyLabel.font.withSize(30)
        secondaryCurrencyLabel.textColor = .gray

        let viewController = SettingsViewController()
        setInitialViewController(viewController)
        
        title = "scene.settings.title".localized
    }
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
