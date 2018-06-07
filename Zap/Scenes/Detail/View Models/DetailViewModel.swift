//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

protocol DetailViewModel {
    var detailViewControllerTitle: String { get }
    var detailCells: MutableObservableArray<DetailCellType> { get }
}

extension DetailViewModel {
    func blockExplorerCell(txid: String, title: String, lightningService: LightningService) -> DetailCellType? {
        let network = lightningService.infoService.network.value
        if let url = Settings.blockExplorer.url(network: network, txid: txid) {
            let info = DetailTransactionHashTableViewCell.Info(title: title, transactionUrl: url, transactionHash: txid)
            return .transactionHash(info)
        }
        return nil
    }
}

final class DetailViewModelFactory {
    static func instantiate(from transactionViewModel: TransactionViewModel, lightningService: LightningService) -> DetailViewModel {
        
        if let transactionViewModel = transactionViewModel as? OnChainTransactionViewModel {
            return OnChainTransactionDetailViewModel(onChainTransaction: transactionViewModel.onChainTransaction, annotation: transactionViewModel.annotation, lightningService: lightningService)
        } else if let transactionViewModel = transactionViewModel as? LightningPaymentViewModel {
            return LightningPaymentDetailViewModel(lightningPayment: transactionViewModel.lightningPayment, annotation: transactionViewModel.annotation, lightningService: lightningService)
        } else if let transactionViewModel = transactionViewModel as? LightningInvoiceViewModel {
            return LightningInvoiceDetailViewModel(lightningInvoice: transactionViewModel.lightningInvoice, annotation: transactionViewModel.annotation, lightningService: lightningService)
        }
        fatalError("TransactionViewModel not supported")
    }
}
