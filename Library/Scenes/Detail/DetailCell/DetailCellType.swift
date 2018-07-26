//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning

enum DetailCellType {
    case destructiveAction(DetailDestructiveActionTableViewCell.Info)
    case info(DetailTableViewCell.Info)
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
    
    static func hideTransactionCell(transaction: Transaction, annotation: TransactionAnnotation, transactionListViewModel: TransactionListViewModel) -> DetailCellType {
        if annotation.isHidden {
            return .destructiveAction(DetailDestructiveActionTableViewCell.Info(title: "scene.transaction_detail.unarchive_button".localized, type: .unarchiveTransaction, action: { completion in
                transactionListViewModel.setTransactionHidden(transaction, hidden: false)
                completion(Result(value: Success()))
            }))
        } else {
            return .destructiveAction(DetailDestructiveActionTableViewCell.Info(title: "scene.transaction_detail.archive_button".localized, type: .archiveTransaction, action: { completion in
                transactionListViewModel.setTransactionHidden(transaction, hidden: true)
                completion(Result(value: Success()))
            }))
        }
    }
    
    static func memoCell(transaction: Transaction, annotation: Observable<TransactionAnnotation>, transactionListViewModel: TransactionListViewModel, placeholder: String) -> DetailCellType {
        return .memo(DetailMemoTableViewCell.Info(memo: annotation, placeholder: placeholder) {
            transactionListViewModel.updateAnnotation(annotation.value.settingMemo(to: $0), for: transaction)
        })
    }
}

protocol DetailCellDelegate: class {
    func dismiss()
    func presentSafariViewController(for url: URL)
}
