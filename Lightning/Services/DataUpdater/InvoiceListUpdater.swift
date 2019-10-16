//
//  Lightning
//
//  Created by 0 on 02.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import ReactiveKit
import SwiftLnd

final class InvoiceListUpdater: GenericListUpdater {
    typealias Item = Invoice

    private let api: LightningApi
    private let invoiceSettledObserver: AnyObserver<Void, Never>
    
    let invoiceSettledSignal: Signal<Void, Never>
    let items = MutableObservableArray<Invoice>()
    
    init(api: LightningApi) {
        self.api = api
        
        let (signal, observer) = Signal<Void, Never>.withObserver()
        
        self.invoiceSettledSignal = signal
        self.invoiceSettledObserver = observer
        
        api.subscribeInvoices { [weak self] in
            if case .success(let invoice) = $0 {
                Logger.info("new invoice: \(invoice)")

                self?.appendOrReplace(invoice)
                if invoice.state == .settled {
                    self?.invoiceSettledObserver.receive()
                    NotificationCenter.default.post(name: .receivedTransaction, object: nil, userInfo: [LightningService.transactionNotificationName: invoice])
                }
            }
        }
    }

    func update() {
        api.invoices { [weak self] in
            if case .success(let invoices) = $0 {
                self?.items.replace(with: invoices)
            }
        }
    }
}
