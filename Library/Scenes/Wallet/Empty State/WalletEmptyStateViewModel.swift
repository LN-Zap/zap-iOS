//
//  Library
//
//  Created by 0 on 30.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

final class WalletEmptyStateViewModel: EmptyStateViewModel {
    let title = L10n.Scene.Wallet.EmptyState.title
    let message = L10n.Scene.Wallet.EmptyState.message
    let buttonTitle = L10n.Scene.Wallet.EmptyState.buttonTitle
    let image = Emoji.image(emoji: "🚀")

    let buttonEnabled = Observable(true)

    private let lightningService: LightningService
    private let fundButtonTapped: (BitcoinURI) -> Void
    private var cachedPaymentURI = [OnChainRequestAddressType: BitcoinURI]()

    init(lightningService: LightningService, fundButtonTapped: @escaping (BitcoinURI) -> Void) {
        self.lightningService = lightningService
        self.fundButtonTapped = fundButtonTapped
    }

    func actionButtonTapped() {
        buttonEnabled.value = false
        getAddress { [weak self] bitcoinURI in
            DispatchQueue.main.async {
                self?.buttonEnabled.value = true
                self?.fundButtonTapped(bitcoinURI)
            }
        }
    }

    func getAddress(completion: @escaping (BitcoinURI) -> Void) {
        let selectedAddressType = Settings.shared.onChainRequestAddressType.value
        if let paymentURI = cachedPaymentURI[selectedAddressType] {
            completion(paymentURI)
            return
        }

        lightningService.transactionService.newAddress(with: selectedAddressType) { [weak self] result in
            switch result {
            case .success(let address):
                guard let paymentURI = BitcoinURI(address: address, amount: nil, memo: nil, lightningFallback: nil) else { return }
                self?.cachedPaymentURI[selectedAddressType] = paymentURI
                completion(paymentURI)
            case .failure:
                break
            }
        }
    }
}
