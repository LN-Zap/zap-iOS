//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

public final class RequestViewModelFactory {
    public static func create() -> RequestViewModel? {
        guard let api = LndConnection.current.api else { return nil }
        let lightningService = LightningService(api: api)
        return RequestViewModel(transactionService: lightningService.transactionService)
    }
}

public final class RequestViewModel {
    public enum RequestMethod {
        case lightning
        case onChain
    }
    
    private let transactionService: TransactionService
    private var cachedOnChainAddress: String?

    public var requestMethod = RequestMethod.lightning
    public var memo: String?
    public var amount: Satoshi = 0
    
    init(transactionService: TransactionService) {
        self.transactionService = transactionService
    }
    
    public func create(callback: @escaping (QRCodeDetailViewModel) -> Void) {
        switch requestMethod {
        case .lightning:
            createLightning(callback: callback)
        case .onChain:
            createOnChain(callback: callback)
        }
    }
    
    private func createLightning(callback: @escaping (QRCodeDetailViewModel) -> Void) {
        transactionService.addInvoice(amount: amount, memo: memo) { result in
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
            transactionService.newAddress { [weak self] result in
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
        guard let uri = BitcoinURI.from(address: address, amount: amount, message: memo) else { return nil }
        return OnChainRequestQRCodeViewModel(address: uri)
    }
}
