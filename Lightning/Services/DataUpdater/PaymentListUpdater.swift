//
//  Lightning
//
//  Created by 0 on 02.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import SwiftLnd

final class PaymentListUpdater: ListUpdater {
    private let api: LightningApiProtocol

    let payments = MutableObservableArray<Payment>()

    init(api: LightningApiProtocol) {
        self.api = api
    }

    func update() {
        api.payments { [weak self] in
            if case .success(let payments) = $0 {
                self?.payments.replace(with: payments)
            }
        }
    }

    func add(payment: Payment) {
        payments.append(payment)
    }
}
