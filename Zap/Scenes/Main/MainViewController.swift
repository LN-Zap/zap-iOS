//
//  Zap
//
//  Created by Otto Suess on 26.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

extension UIStoryboard {
    // swiftlint:disable:next function_parameter_count
    static func instantiateMainViewController(with viewModel: ViewModel, settingsButtonTapped: @escaping () -> Void, sendButtonTapped: @escaping () -> Void, requestButtonTapped: @escaping () -> Void, transactionsButtonTapped: @escaping () -> Void, networkButtonTapped: @escaping () -> Void) -> MainViewController {
        let mainViewController = Storyboard.main.instantiate(viewController: MainViewController.self)
        mainViewController.viewModel = viewModel
        
        mainViewController.settingsButtonTapped = settingsButtonTapped
        mainViewController.sendButtonTapped = sendButtonTapped
        mainViewController.requestButtonTapped = requestButtonTapped
        mainViewController.transactionsButtonTapped = transactionsButtonTapped
        mainViewController.networkButtonTapped = networkButtonTapped
        
        return mainViewController
    }
}

final class MainViewController: UIViewController, ContainerViewController {
    var viewModel: ViewModel?
 
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var fiatBalanceLabel: UILabel!
    @IBOutlet private weak var expandHeaderButton: UIButton!
    @IBOutlet private weak var selecteButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var transactionsButton: UIButton!
    @IBOutlet private weak var networkButton: UIButton!
    
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var requestButton: UIButton!
    
    // ContainerViewController Protocol
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    weak var currentViewController: UIViewController?
    
    fileprivate var settingsButtonTapped: (() -> Void)?
    fileprivate var sendButtonTapped: (() -> Void)?
    fileprivate var requestButtonTapped: (() -> Void)?
    fileprivate var transactionsButtonTapped: (() -> Void)?
    fileprivate var networkButtonTapped: (() -> Void)?

    private enum ContainerContent {
        case transactions
        case network
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Style.button.apply(to: transactionsButton, networkButton, sendButton, requestButton)
        transactionsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        transactionsButton.tintColor = .white
        networkButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        networkButton.tintColor = .white
        
        sendButton.tintColor = .white
        requestButton.tintColor = .white
        
        UIView.performWithoutAnimation {
            sendButton.setTitle("Send", for: .normal)
            sendButton.layoutIfNeeded()
            requestButton.setTitle("Receive", for: .normal)
            requestButton.layoutIfNeeded()
            transactionsButton.setTitle("Transactions", for: .normal)
            transactionsButton.layoutIfNeeded()
            networkButton.setTitle("Network", for: .normal)
            networkButton.layoutIfNeeded()
        }
        
        Style.label.apply(to: aliasLabel, balanceLabel, fiatBalanceLabel)
        aliasLabel.textColor = .white
        balanceLabel.textColor = .white
        balanceLabel.font = balanceLabel.font.withSize(30)
        fiatBalanceLabel.textColor = .gray
        
        [viewModel?.balance.total.bind(to: balanceLabel.reactive.text, currency: Settings.primaryCurrency),
         viewModel?.balance.total.bind(to: fiatBalanceLabel.reactive.text, currency: Settings.secondaryCurrency),
         viewModel?.info.alias.bind(to: aliasLabel.reactive.text)]
            .dispose(in: reactive.bag)
        
        segmentedControl(select: .transactions)
    }
    
    private func segmentedControl(select selection: ContainerContent) {
        if selection == .network {
            networkButton.setTitleColor(.white, for: .normal)
            transactionsButton.setTitleColor(.lightGray, for: .normal)
        } else {
            networkButton.setTitleColor(.lightGray, for: .normal)
            transactionsButton.setTitleColor(.white, for: .normal)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: [], animations: {
            self.selecteButtonLeadingConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(selection == .network ? 700 : 800))
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction private func presentSettings(_ sender: Any) {
        settingsButtonTapped?()
    }
    
    @IBAction private func showTransactions(_ smender: Any) {
        segmentedControl(select: .transactions)
        transactionsButtonTapped?()
    }
    
    @IBAction private func showNetwork(_ sender: Any) {
        segmentedControl(select: .network)
        networkButtonTapped?()
    }
    
    @IBAction private func presentSend(_ sender: Any) {
        sendButtonTapped?()
    }
    
    @IBAction private func presentRequest(_ sender: Any) {
        requestButtonTapped?()
    }
    
    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.swapCurrencies()
    }
}
