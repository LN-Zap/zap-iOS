//
//  Zap
//
//  Created by Otto Suess on 26.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class MainViewController: UIViewController, ContainerViewController {
    var viewModel: ViewModel?
 
    @IBOutlet private weak var balanceView: UIView!
    @IBOutlet private weak var segmentedControlView: UIView!
    
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var fiatBalanceLabel: UILabel!
    @IBOutlet private weak var expandHeaderButton: UIButton!
    
    @IBOutlet private weak var selectedButtonbackgroundView: UIView!
    @IBOutlet private weak var selecteButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var transactionsButton: UIButton!
    @IBOutlet private weak var networkButton: UIButton!
    
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var requestButton: UIButton!
    
    // ContainerViewController Protocol
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?
    
    private enum ContainerContent {
        case transactions
        case network
    }
    
    private var transactionViewController: TransactionListViewController {
        let viewController = Storyboard.transactionList.initial(viewController: TransactionListViewController.self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    private var channelViewController: ChannelListViewController {
        let viewController = Storyboard.channelList.initial(viewController: ChannelListViewController.self)
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        balanceView.backgroundColor = UIColor.zap.darkBackground
        segmentedControlView.backgroundColor = UIColor.zap.mediumBackground
        selectedButtonbackgroundView.backgroundColor = UIColor.zap.darkBackground
        
        Style.button.apply(to: transactionsButton, networkButton, sendButton, requestButton)
        transactionsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        transactionsButton.tintColor = .white
        networkButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        networkButton.tintColor = .white
        
        sendButton.tintColor = .white
        requestButton.tintColor = .white
        
        Style.label.apply(to: aliasLabel, balanceLabel, fiatBalanceLabel)
        aliasLabel.textColor = .white
        balanceLabel.textColor = .white
        balanceLabel.font = balanceLabel.font.withSize(30)
        fiatBalanceLabel.textColor = .gray
        
        [viewModel?.balance.total.bind(to: balanceLabel.reactive.text, currency: Settings.primaryCurrency),
         viewModel?.balance.total.bind(to: fiatBalanceLabel.reactive.text, currency: Settings.secondaryCurrency),
         viewModel?.info.alias.bind(to: aliasLabel.reactive.text)]
            .dispose(in: reactive.bag)
        
        setInitialViewController(transactionViewController)
        segmentedControl(select: .transactions)
    }
    
    private func segmentedControl(select selection: ContainerContent) {
        if selection == .network {
            networkButton.imageView?.tintColor = UIColor.zap.tint
            transactionsButton.imageView?.tintColor = .lightGray
            networkButton.setTitleColor(.white, for: .normal)
            transactionsButton.setTitleColor(.lightGray, for: .normal)
        } else {
            networkButton.imageView?.tintColor = .lightGray
            transactionsButton.imageView?.tintColor = UIColor.zap.bottomGradientLeft
            networkButton.setTitleColor(.lightGray, for: .normal)
            transactionsButton.setTitleColor(.white, for: .normal)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [], animations: {
            self.selecteButtonLeadingConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(selection == .network ? 700 : 800))
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction private func transactionsButtonTapped(_ smender: Any) {
        segmentedControl(select: .transactions)
        switchToViewController(transactionViewController)
    }
    
    @IBAction private func networkButtonTapped(_ sender: Any) {
        segmentedControl(select: .network)
        switchToViewController(channelViewController)
    }
    
    @IBAction private func expandHeaderButtonTapped(_ sender: Any) {
        let viewController = Storyboard.settings.initial(viewController: UINavigationController.self)

        if let settingsContainerViewController = viewController.topViewController as? SettingsContainerViewController {
            settingsContainerViewController.viewModel = viewModel
        }

        present(viewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController else { return }
        
        if let sendViewController = navigationController.topViewController as? QRCodeScannerViewController {
            sendViewController.viewModel = viewModel
            sendViewController.strategy = SendQRCodeScannerStrategy()
        } else if let requestViewController = navigationController.topViewController as? RequestViewController {
            requestViewController.viewModel = viewModel
        }
    }
    
    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.swapCurrencies()
    }
}
