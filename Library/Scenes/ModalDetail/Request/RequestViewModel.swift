//
//  Zap
//
//  Created by Otto Suess on 07.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

public enum Layer {
    case onChain
    case lightning
}

public final class RequestViewModel {
    private let transactionService: TransactionService
    private let channelService: ChannelService
    private var cachedOnChainAddress: BitcoinAddress?

    public var requestMethod = Layer.lightning
    public var memo: String?
    public var amount: Satoshi = 0

    var maxRemoteBalance: Satoshi {
        return channelService.maxRemoteBalance
    }

    public var trimmedMemo: String? {
        return memo?.trimAllWhitespacesAndNewlines()
    }

    init(lightningService: LightningService) {
        transactionService = lightningService.transactionService
        channelService = lightningService.channelService
    }

    func create(completion: @escaping ApiCompletion<QRCodeDetailViewModel>) {
        switch requestMethod {
        case .lightning:
            createLightning(completion: completion)
        case .onChain:
            createOnChain(completion: completion)
        }
    }

    private func createLightning(completion: @escaping ApiCompletion<QRCodeDetailViewModel>) {
        let expiry = Settings.shared.lightningRequestExpiry.value
        transactionService.addInvoice(amount: amount, memo: trimmedMemo, expiry: expiry) { result in
            completion(result.flatMap {
                guard let invoiceURI = LightningInvoiceURI(string: $0) else { return .failure(LndApiError.unknownError) }
                return .success(RequestQRCodeViewModel(paymentURI: invoiceURI))
            })
        }
    }

    private func createOnChain(completion: @escaping ApiCompletion<QRCodeDetailViewModel>) {
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

    private func onChainRequestViewModel(for address: BitcoinAddress) -> RequestQRCodeViewModel? {
        guard let uri = BitcoinURI(address: address, amount: amount, memo: trimmedMemo, lightningFallback: nil) else { return nil }
        return RequestQRCodeViewModel(paymentURI: uri)
    }
}
