//
//  Zap
//
//  Created by Otto Suess on 05.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

enum SendLightningInvoiceError {
    case none
    case expired(Date)
    case duplicate
}

final class SendLightningInvoiceViewModel {
    private let viewModel: ViewModel
    
    let memo = Observable<String?>(nil)
    let satoshis = Observable<Satoshi>(0)
    let destination = Observable<String?>(nil)
    let invoiceError = Observable<SendLightningInvoiceError>(.none)
    
    private var paymentRequest: PaymentRequest?
    
    init (viewModel: ViewModel, lightningInvoice: String) {
        self.viewModel = viewModel
        
        var lightningInvoice = lightningInvoice
        
        let prefix = "lightning:"
        if lightningInvoice.starts(with: prefix) {
            lightningInvoice = String(lightningInvoice.dropFirst(prefix.count))
        }
        
        viewModel.decodePaymentRequest(lightningInvoice) { [weak self] result in
            guard let paymentRequest = result.value else { return }
            self?.updatePaymentRequest(paymentRequest)
        }
    }
    
    func send(callback: @escaping (Bool) -> Void) {
        guard let paymentRequest = paymentRequest else { return }
        viewModel.sendPayment(paymentRequest, callback: callback)
    }
    
    private func updatePaymentRequest(_ paymentRequest: PaymentRequest) {
        self.paymentRequest = paymentRequest
        
        if let memo = paymentRequest.memo {
            self.memo.value = "Memo: " + memo
        }
        satoshis.value = paymentRequest.amount
        destination.value = paymentRequest.destination
        
        if viewModel.transactions.value.contains(where: { $0.id == paymentRequest.paymentHash }) {
            invoiceError.value = .duplicate
        } else if paymentRequest.expiryDate < Date() {
            invoiceError.value = .expired(paymentRequest.expiryDate)
        } else {
            invoiceError.value = .none
        }
    }
}
