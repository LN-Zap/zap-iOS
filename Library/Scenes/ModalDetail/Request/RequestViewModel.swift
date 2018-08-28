//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning

// Only used by Messages Extension
public enum RequestViewModelFactory {
    public static func create() -> RequestViewModel? {
        let zapSerview = RootViewModel()
        zapSerview.connect()
        guard let lightningService = zapSerview.lightningService else { return nil }
        return RequestViewModel(transactionService: lightningService.transactionService)
    }
}

public final class RequestViewModel {
    public enum RequestMethod {
        case lightning
        case onChain
    }
    
    private let transactionService: TransactionService
    private var cachedOnChainAddress: BitcoinAddress?

    public var requestMethod = RequestMethod.lightning
    public var memo: String?
    public var amount: Satoshi = 0
    
    public var trimmedMemo: String? {
        return memo?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    init(transactionService: TransactionService) {
        self.transactionService = transactionService
    }
    
    public func create(completion: @escaping (Result<QRCodeDetailViewModel>) -> Void) {
        switch requestMethod {
        case .lightning:
            createLightning(completion: completion)
        case .onChain:
            createOnChain(completion: completion)
        }
    }
    
    private func createLightning(completion: @escaping (Result<QRCodeDetailViewModel>) -> Void) {
        transactionService.addInvoice(amount: amount, memo: trimmedMemo) { result in
            completion(result.flatMap {
                guard let invoiceURI = LightningInvoiceURI(string: $0) else { return .failure(LndApiError.unknownError) }
                return .success(LightningRequestQRCodeViewModel(paymentURI: invoiceURI))
            })
        }
    }
    
    private func createOnChain(completion: @escaping (Result<QRCodeDetailViewModel>) -> Void) {
        if let address = cachedOnChainAddress,
            let viewModel = onChainRequestViewModel(for: address) {
            completion(.success(viewModel))
        } else {
            let type = Settings.shared.onChainRequestAddressType.value
            transactionService.newAddress(with: type) { [weak self] result in
                completion(result.flatMap {
                    guard let viewModel = self?.onChainRequestViewModel(for: $0) else { return .failure(LndApiError.unknownError) }
                    self?.cachedOnChainAddress = $0
                    return .success(viewModel)
                })
            }
        }
    }
    
    private func onChainRequestViewModel(for address: BitcoinAddress) -> OnChainRequestQRCodeViewModel? {
        guard let uri = BitcoinURI(address: address, amount: amount, memo: trimmedMemo, lightningFallback: nil) else { return nil }
        return OnChainRequestQRCodeViewModel(paymentURI: uri)
    }
}
