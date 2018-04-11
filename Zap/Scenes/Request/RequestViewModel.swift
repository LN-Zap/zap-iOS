//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

enum RequestMethod {
    case lightning
    case onChain
}

final class RequestViewModel {
    private let maxPaymentAllowed: Satoshi = 4294967
    private let viewModel: ViewModel
    private var cachedOnChainAddress: String?
    
    let isAmountValid = Observable(true)
    
    var requestMethod = RequestMethod.lightning
    
    var satoshis: Satoshi {
        guard let amountString = amountString.value else { return 0 }
        return Satoshi.from(string: amountString, unit: .bit) ?? 0
    }
    
    let amountString = Observable<String?>(nil)
    var memo: String?
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    func updateAmount(_ amount: String?) {
        amountString.value = amount
        if amount != nil {
            isAmountValid.value = satoshis <= maxPaymentAllowed
        }
    }
    
    func create(callback: @escaping (QRCodeDetailViewModel) -> Void) {
        switch requestMethod {
        case .lightning:
            createLightning(callback: callback)
        case .onChain:
            createOnChain(callback: callback)
        }
    }
    
    private func createLightning(callback: @escaping (QRCodeDetailViewModel) -> Void) {
        viewModel.addInvoice(amount: satoshis, memo: memo) { result in
            guard let invoice = result.value else { return }
            let viewModel = LightningRequestQRCodeViewModel(invoice: invoice)
            callback(viewModel)
        }
    }
    
    private func createOnChain(callback: @escaping (QRCodeDetailViewModel) -> Void) {
        if let address = cachedOnChainAddress,
            let viewModel = onChainRequestViewModel(for: address) {
            callback(viewModel)
        } else {
            viewModel.newAddress { [weak self] result in
                guard
                    let address = result.value,
                    let viewModel = self?.onChainRequestViewModel(for: address)
                    else { return }
                self?.cachedOnChainAddress = address
                callback(viewModel)
            }
        }

    }
    
    private func onChainRequestViewModel(for address: String) -> OnChainRequestQRCodeViewModel? {
        guard let uri = BitcoinURI.from(address: address, amount: satoshis, message: memo) else { return nil }
        return OnChainRequestQRCodeViewModel(address: uri)
    }
}
