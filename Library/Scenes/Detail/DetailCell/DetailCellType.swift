//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

enum DetailCellType {
    case balance(DetailBalanceTableViewCell.Info)
    case destructiveAction(DetailDestructiveActionTableViewCell.Info)
    case info(DetailTableViewCell.Info)
    case legend(DetailLegendTableViewCell.Info)
    case memo(DetailMemoTableViewCell.Info)
    case qrCode(String)
    case separator
    case timer(DetailTimerTableViewCell.Info)
    case transactionHash(DetailTransactionHashTableViewCell.Info)

    static var titleFont = UIFont.zap.regular.withSize(14)
    static var dataFont = UIFont.zap.light.withSize(14)
    
    static func blockExplorerCell(txid: String, title: String, network: Network) -> DetailCellType? {
        if let url = Settings.shared.blockExplorer.value.url(network: network, txid: txid) {
            let info = DetailTransactionHashTableViewCell.Info(title: title, transactionUrl: url, transactionHash: txid)
            return .transactionHash(info)
        }
        return nil
    }
    
    static func hideTransactionCell(transaction: Transaction, transactionListViewModel: TransactionListViewModel) -> DetailCellType {
        return .destructiveAction(DetailDestructiveActionTableViewCell.Info(title: "scene.transaction_detail.archive_button".localized, type: .archiveTransaction, action: {
            transactionListViewModel.hideTransaction(transaction)
        }))
    }
}

protocol DetailCellDelegate: class {
    func dismiss()
    func presentSafariViewController(for url: URL)
    func closeChannel(_ channel: Channel, nodeAlias: String, closeAction: @escaping () -> Void)
}
