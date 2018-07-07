//
//  Zap
//
//  Created by Otto Suess on 06.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning

final class SendOnChainViewModel {
    private let minimumOnChainTransaction: Satoshi = 547
    
    private let transactionAnnotationStore: TransactionAnnotationStore
    private let lightningService: LightningService
    let bitcoinURI: BitcoinURI
    let validRange: ClosedRange<Satoshi>
    
    let isSendButtonEnabled = Observable(false)
    
    var amount: Satoshi = 0 {
        didSet {
            isSendButtonEnabled.value = validRange.contains(amount)
        }
    }
    
    init(transactionAnnotationStore: TransactionAnnotationStore, lightningService: LightningService, bitcoinURI: BitcoinURI) {
        self.transactionAnnotationStore = transactionAnnotationStore
        self.lightningService = lightningService
        self.bitcoinURI = bitcoinURI
        
        validRange = (minimumOnChainTransaction...lightningService.balanceService.onChain.value)
    }

    func send(callback: @escaping (Result<String>) -> Void) {
        lightningService.transactionService.sendCoins(address: bitcoinURI.address, amount: amount) { [weak self] in
            if let txid = $0.value,
                let memo = self?.bitcoinURI.memo {
                self?.transactionAnnotationStore.udpateMemo(memo, forTransactionId: txid)
            }
            callback($0)
        }
    }
}
