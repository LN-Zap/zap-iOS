//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import SwiftLnd

protocol DetailViewModel {
    var detailViewControllerTitle: String { get }
    var detailCells: MutableObservableArray<DetailCellType> { get }
}

enum DetailViewModelFactory {
    static func instantiate(from transactionViewModel: TransactionViewModel, transactionListViewModel: TransactionListViewModel) -> DetailViewModel {
        
        if let transactionViewModel = transactionViewModel as? OnChainConfirmedTransactionViewModel {
            return OnChainTransactionDetailViewModel(onChainTransaction: transactionViewModel.onChainTransaction, annotation: transactionViewModel.annotation, transactionListViewModel: transactionListViewModel)
        } else if let transactionViewModel = transactionViewModel as? LightningPaymentViewModel {
            return LightningPaymentDetailViewModel(lightningPayment: transactionViewModel.lightningPayment, annotation: transactionViewModel.annotation, transactionListViewModel: transactionListViewModel)
        } else if let transactionViewModel = transactionViewModel as? LightningInvoiceViewModel {
            return LightningInvoiceDetailViewModel(lightningInvoice: transactionViewModel.lightningInvoice, annotation: transactionViewModel.annotation, transactionListViewModel: transactionListViewModel)
        } else if let transactionViewModel = transactionViewModel as? OnChainUnconfirmedTransactionViewModel {
            return OnChainTransactionDetailViewModel(onChainTransaction: transactionViewModel.unconfirmedTransaction, annotation: transactionViewModel.annotation, transactionListViewModel: transactionListViewModel)
        }
        fatalError("TransactionViewModel not supported")
    }
}
