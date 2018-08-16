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
    case transactionHash(DetailBlockExplorerTableViewCell.Info)

    static var titleFontStyle = Style.Label.headline
    static var dataFontStyle = Style.Label.body
    
    static func blockExplorerCell(title: String, code: String, type: BlockExplorer.CodeType) -> DetailCellType {
        let info = DetailBlockExplorerTableViewCell.Info(title: title, code: code, type: type)
        return .transactionHash(info)
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
    func presentBlockExplorer(_ transactionId: String, type: BlockExplorer.CodeType)
}
