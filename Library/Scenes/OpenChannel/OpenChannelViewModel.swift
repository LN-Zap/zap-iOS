//
//  Zap
//
//  Created by Otto Suess on 10.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

final class OpenChannelViewModel: NSObject {
    private let lightningService: LightningService

    let lightningNodeURI: LightningNodeURI

    let subtitle = Observable<String?>(nil)
    let isAmountValid = Observable(true)

    var amount: Satoshi {
        didSet {
            updateSubtitle()
            isAmountValid.value = validRange.contains(amount) && amount < lightningService.balanceService.onChainConfirmed.value
        }
    }

    private let validRange = (LndConstants.minChannelSize...LndConstants.maxChannelSize)

    init(lightningService: LightningService, lightningNodeURI: LightningNodeURI) {
        self.lightningService = lightningService
        self.lightningNodeURI = lightningNodeURI

        amount = max(min(lightningService.balanceService.onChainConfirmed.value * 0.75, LndConstants.maxChannelSize), LndConstants.minChannelSize)

        super.init()

        Settings.shared.primaryCurrency
            .observeNext { [weak self] _ in
                self?.updateSubtitle()
            }
            .dispose(in: reactive.bag)
    }

    private func updateSubtitle() {
        let currency = Settings.shared.primaryCurrency.value

        if amount < LndConstants.minChannelSize,
            let amount = currency.format(satoshis: LndConstants.minChannelSize) {
            subtitle.value = L10n.Scene.OpenChannel.Subtitle.minimumSize(amount)
        } else if amount > LndConstants.maxChannelSize,
            let amount = currency.format(satoshis: LndConstants.maxChannelSize) {
            subtitle.value = L10n.Scene.OpenChannel.Subtitle.maximumSize(amount)
        } else if let amount = currency.format(satoshis: lightningService.balanceService.onChainConfirmed.value) {
            subtitle.value = L10n.Scene.OpenChannel.Subtitle.balance(amount)
        }
    }

    func openChannel(completion: @escaping ApiCompletion<ChannelPoint>) {
        let csvDelay = lightningService.connection == .local ? 2016 : nil // use 2 weeks csv delay for local nodes.
        lightningService.channelService.open(lightningNodeURI: lightningNodeURI, csvDelay: csvDelay, amount: amount, completion: completion)
    }
}
