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
        guard let viewModel = viewModel else { fatalError("viewModel not set") }
        return UIStoryboard.instantiateTransactionListViewController(with: viewModel)
    }
    
    private var channelViewController: ChannelListViewController {
        guard let viewModel = viewModel else { fatalError("viewModel not set") }
        return UIStoryboard.instantiateChannelListViewController(with: viewModel)
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
        
        setContainerContent(transactionViewController)
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
        setContainerContent(transactionViewController)
    }
    
    @IBAction private func networkButtonTapped(_ sender: Any) {
        segmentedControl(select: .network)
        setContainerContent(channelViewController)
    }
    
    @IBAction private func expandHeaderButtonTapped(_ sender: Any) {
        guard let viewModel = viewModel else { fatalError("viewModel not set") }
        let viewController = UIStoryboard.instantiateSettingsContainerViewController(with: viewModel)
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction private func presentSend(_ sender: Any) {
        guard let viewModel = viewModel else { fatalError("viewModel not set.") }
        let viewController = UIStoryboard.instantiateQRCodeScannerViewController(with: viewModel, strategy: SendQRCodeScannerStrategy())
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction private func presentRequest(_ sender: Any) {
        guard let viewModel = viewModel else { fatalError("viewModel not set.") }
        let viewController = UIStoryboard.instantiateRequestViewController(with: viewModel)
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction private func swapCurrencyButtonTapped(_ sender: Any) {
        Settings.swapCurrencies()
    }
}
