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
    let shoppingCartViewModel: ShoppingCartViewModel?
    
    let totalAmount: Observable<Satoshi>
    let tipAmount: Observable<Satoshi>
    let amount: Satoshi
    var memo: Observable<String>
    
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
                updateMemo()
            }
        }
    }
    var bitcoinURI: BitcoinURI?
    var lightningInvoiceURI: LightningInvoiceURI?
    
    init(amount: Satoshi, transactionService: TransactionService, shoppingCartViewModel: ShoppingCartViewModel?) {
        self.amount = amount
        self.transactionService = transactionService
        self.shoppingCartViewModel = shoppingCartViewModel
        
        totalAmount = Observable(amount)
        tipAmount = Observable(0)
        memo = Observable("")
        updateMemo()
    }
    
    func bitcoinURI(completion: @escaping (BitcoinURI) -> Void) {
        if let bitcoinURI = bitcoinURI {
            completion(bitcoinURI)
        } else {
            transactionService.newAddress(with: .nestedPubkeyHash) { [totalAmount, memo, weak self] in
                guard
                    let address = $0.value,
                    let bitcoinURI = BitcoinURI(address: address, amount: totalAmount.value, memo: memo.value, lightningFallback: nil)
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
            transactionService.addInvoice(amount: totalAmount.value, memo: memo.value) { [weak self] in
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
    
    private func updateMemo() {
        var result = UserDefaults.Keys.posMemo.get(defaultValue: "")
        let separator = " \\ "
        
        if let userName: String = UserDefaults.Keys.posUserName.get() {
            result += "\(separator)\(userName)"
        }
        
        let tipString: String
        if let selectedTipIndex = selectedTipIndex {
            tipString = String(tipPercentages[selectedTipIndex])
        } else {
            tipString = "0"
        }
        
        memo.value = result + "\(separator)tip: \(tipString)%"
    }
}
