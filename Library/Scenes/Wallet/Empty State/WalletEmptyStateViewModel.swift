//
//  Library
//
//  Created by 0 on 30.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC

final class WalletEmptyStateViewModel {
    private let lightningService: LightningService

    var paymentURI: BitcoinURI?

    init(lightningService: LightningService) {
        self.lightningService = lightningService
    }

    func getAddress(completion: @escaping (BitcoinURI) -> Void) {
        if let paymentURI = paymentURI {
            completion(paymentURI)
            return
        }

        lightningService.transactionService.newAddress(with: .witnessPubkeyHash) { [weak self] result in
            switch result {
            case .success(let address):
                guard let paymentURI = BitcoinURI(address: address, amount: nil, memo: nil, lightningFallback: nil) else { return }
                self?.paymentURI = paymentURI
                completion(paymentURI)
            case .failure:
                break
            }
        }
    }
}
