//
//  Zap
//
//  Created by Otto Suess on 05.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class SendViewModel {
    private let viewModel: ViewModel
    
    let hasPaymentRequest = Observable(false)
    let memo = Observable<String?>(nil)
    let satoshis = Observable<Satoshi?>(nil)
    
    private var paymentRequest: PaymentRequest?
    
    init (viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    func send() {
        guard let paymentRequest = paymentRequest else { return }
        viewModel.sendPayment(paymentRequest)
    }
    
    private func updatePaymentRequest(_ paymentRequest: PaymentRequest) {
        self.paymentRequest = paymentRequest
        
        if let memo = paymentRequest.memo {
            self.memo.value = "Memo:\n\n" + memo
        }
        satoshis.value = paymentRequest.amount
        
        hasPaymentRequest.value = true
    }
    
    func updatePaymentRequest(_ string: String) {
        var string = string
        
        let prefix = "lightning:"
        if string.starts(with: prefix) {
            string = String(string.dropFirst(prefix.count))
        }

        viewModel.decodePaymentRequest(string) { [weak self] result in
            guard let paymentRequest = result.value else { return }
            self?.updatePaymentRequest(paymentRequest)
        }
    }
    
    func paste() {
        if let string = UIPasteboard.general.string {
            updatePaymentRequest(string)
        }
    }
}
