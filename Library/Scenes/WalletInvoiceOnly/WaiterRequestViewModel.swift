//
//  Library
//
//  Created by Otto Suess on 17.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC

final class WaiterRequestViewModel {
    let transactionService: TransactionService
    
    let totalAmount: Observable<Satoshi>
    let tipAmount: Observable<Satoshi>
    let amount: Satoshi
    let memo: String
    let tipPercentages = [10, 15, 20]
    var selectedTipIndex: Int? {
        didSet {
            if let selectedTipIndex = selectedTipIndex, selectedTipIndex < tipPercentages.count {
                tipAmount.value = Decimal(tipPercentages[selectedTipIndex]) / 100 * amount
                totalAmount.value = amount + tipAmount.value
            } else {
                totalAmount.value = amount
                tipAmount.value = 0
            }
            
            if oldValue != selectedTipIndex {
                bitcoinURI = nil
                lightningInvoiceURI = nil
            }
        }
    }
    private var bitcoinURI: BitcoinURI?
    private var lightningInvoiceURI: LightningInvoiceURI?
    
    init(amount: Satoshi, transactionService: TransactionService) {
        self.amount = amount
        self.transactionService = transactionService
        totalAmount = Observable(amount)
        tipAmount = Observable(0)
        memo = "Fette, fette super party"
    }
    
    func bitcoinURI(completion: @escaping (BitcoinURI) -> Void) {
        if let bitcoinURI = bitcoinURI {
            completion(bitcoinURI)
        } else {
            transactionService.newAddress(with: .nestedPubkeyHash) { [totalAmount, memo, weak self] in
                guard
                    let address = $0.value,
                    let bitcoinURI = BitcoinURI(address: address, amount: totalAmount.value, memo: memo, lightningFallback: nil)
                    else { return }
                
                self?.bitcoinURI = bitcoinURI
                DispatchQueue.main.async {
                    completion(bitcoinURI)
                }
            }
        }
    }
    
    func lightningInvoiceURI(completion: @escaping (LightningInvoiceURI) -> Void) {
        if let lightningInvoiceURI = lightningInvoiceURI {
            completion(lightningInvoiceURI)
        } else {
            transactionService.addInvoice(amount: totalAmount.value, memo: memo) { [weak self] in
                guard
                    let invoice = $0.value,
                    let lightningInvoiceURI = LightningInvoiceURI(string: invoice)
                    else { return }
                
                self?.lightningInvoiceURI = lightningInvoiceURI
                DispatchQueue.main.async {
                    completion(lightningInvoiceURI)
                }
            }
        }
    }
}
