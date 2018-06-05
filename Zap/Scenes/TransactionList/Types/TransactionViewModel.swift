//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

enum TransactionIcon {
    case onChain
    case lightningPayment
    case settledInvoice
    case unsettledInvoice
    case expiredInvoice
    case openChannel
    case unconfirmed
    
    var image: UIImage {
        switch self {
        case .onChain:
            return #imageLiteral(resourceName: "icon_transaction_onchain")
        case .lightningPayment:
            return #imageLiteral(resourceName: "icon_transaction_lightning")
        case .settledInvoice:
            return #imageLiteral(resourceName: "icon_transaction_invoice")
        case .unsettledInvoice:
            return #imageLiteral(resourceName: "icon_transaction_invoice_pending")
        case .expiredInvoice:
            return #imageLiteral(resourceName: "icon_transaction_invoice")
        case .openChannel:
            return #imageLiteral(resourceName: "icon_transaction_openchannel")
        case .unconfirmed:
            return #imageLiteral(resourceName: "icon_transaction_unconfirmed")
        }
    }
}

protocol TransactionViewModel: DetailViewModel {
    var id: String { get }
    var annotation: Observable<TransactionAnnotation> { get }
    var date: Date { get }
    var displayText: Observable<String> { get }
    var amount: Observable<Satoshi?> { get }
    var icon: Observable<TransactionIcon> { get }
}
