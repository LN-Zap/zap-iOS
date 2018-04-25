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
        
        balanceView.backgroundColor = Color.darkBackground
        segmentedControlView.backgroundColor = Color.mediumBackground
        
        Style.button.apply(to: transactionsButton, networkButton)
        transactionsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        transactionsButton.tintColor = .white
        networkButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        networkButton.tintColor = .white
        
        Style.button.apply(to: sendButton, requestButton)
        sendButton.tintColor = .white
        requestButton.tintColor = .white
        
        Style.label.apply(to: aliasLabel, balanceLabel, fiatBalanceLabel)
        aliasLabel.textColor = .white
        balanceLabel.textColor = .white
        balanceLabel.font = balanceLabel.font.withSize(30)
        fiatBalanceLabel.textColor = .gray
        
        viewModel?.totalBalance
            .bind(to: balanceLabel.reactive.text, currency: Settings.primaryCurrency)
            .dispose(in: reactive.bag)
        
        viewModel?.totalBalance
            .bind(to: fiatBalanceLabel.reactive.text, currency: Settings.secondaryCurrency)
            .dispose(in: reactive.bag)
        
        viewModel?.alias
            .bind(to: aliasLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        setInitialViewController(transactionViewController)
        segmentedControl(select: .transactions)
    }
    
    private func segmentedControl(select selection: ContainerContent) {
        let selectedColor = Color.darkBackground
        networkButton.backgroundColor = selection == .network ? selectedColor : .clear
        transactionsButton.backgroundColor = selection == .transactions ? selectedColor : .clear
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
        let viewController = Storyboard.settings.initial()
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
