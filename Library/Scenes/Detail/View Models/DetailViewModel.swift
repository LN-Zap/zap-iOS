//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

protocol DetailViewModel {
    var detailViewControllerTitle: String { get }
    var detailCells: MutableObservableArray<DetailCellType> { get }
}

final class DetailViewModelFactory {
    static func instantiate(from transactionViewModel: TransactionViewModel, transactionListViewModel: TransactionListViewModel, network: Network) -> DetailViewModel {
        
        if let transactionViewModel = transactionViewModel as? OnChainTransactionViewModel {
            return OnChainTransactionDetailViewModel(onChainTransaction: transactionViewModel.onChainTransaction, annotation: transactionViewModel.annotation, network: network, transactionListViewModel: transactionListViewModel)
        } else if let transactionViewModel = transactionViewModel as? LightningPaymentViewModel {
            return LightningPaymentDetailViewModel(lightningPayment: transactionViewModel.lightningPayment, annotation: transactionViewModel.annotation, transactionListViewModel: transactionListViewModel)
        } else if let transactionViewModel = transactionViewModel as? LightningInvoiceViewModel {
            return LightningInvoiceDetailViewModel(lightningInvoice: transactionViewModel.lightningInvoice, annotation: transactionViewModel.annotation, transactionListViewModel: transactionListViewModel)
        } else if let transactionViewModel = transactionViewModel as? UnconfirmedTransactionViewModel {
            return UnconfirmedTransactionDetailViewModel(unconfirmedTransaction: transactionViewModel.unconfirmedTransaction, annotation: transactionViewModel.annotation, network: network, transactionListViewModel: transactionListViewModel)
        }
        fatalError("TransactionViewModel not supported")
    }
}
