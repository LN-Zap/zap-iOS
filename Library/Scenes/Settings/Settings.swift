//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

public final class Settings: NSObject, Persistable {
    // Persistable
    public typealias Value = SettingsData
    public var data: SettingsData = SettingsData() {
        didSet {
            savePersistable()
        }
    }
    public static var fileName = "settings"

    public struct SettingsData: Codable {
        var isFiatCurrencyPrimary: Bool?
        var fiatCurrency: FiatCurrency?
        var cryptoCurrency: Bitcoin?
        var blockExplorer: BlockExplorer?
        var onChainRequestAddressType: OnChainRequestAddressType?
        var lightningRequestExpiry: ExpiryTime?
        var paymentsPINProtection: Bool?
    }

    public let primaryCurrency: Observable<Currency>
    let secondaryCurrency: Observable<Currency>

    let fiatCurrency: Observable<FiatCurrency>
    let cryptoCurrency: Observable<Bitcoin>
    let blockExplorer: Observable<BlockExplorer>
    let onChainRequestAddressType: Observable<OnChainRequestAddressType>
    let lightningRequestExpiry: Observable<ExpiryTime>
    let paymentsPINProtection: Observable<Bool>

    public static let shared = Settings()

    private init(data: SettingsData?) {
        if let data = data {
            self.data = data
        }

        fiatCurrency = Observable(data?.fiatCurrency ?? FiatCurrency(currencyCode: "USD", symbol: "$", localized: "US Dollar", exchangeRate: 7076.3512))
        cryptoCurrency = Observable(data?.cryptoCurrency ?? .satoshi)

        primaryCurrency = Observable(cryptoCurrency.value)
        secondaryCurrency = Observable(fiatCurrency.value)

        blockExplorer = Observable(data?.blockExplorer ?? .blockstream)
        onChainRequestAddressType = Observable(data?.onChainRequestAddressType ?? .witnessPubkeyHash)
        lightningRequestExpiry = Observable(data?.lightningRequestExpiry ?? .oneHour)
        paymentsPINProtection = Observable(data?.paymentsPINProtection ?? true)
        
        super.init()

        if data?.isFiatCurrencyPrimary == true {
            self.swapCurrencies()
        }
    }

    override convenience init() {
        let data = Settings.decoded
        self.init(data: data)

        setupSavingOnChange()
    }

    private func setupSavingOnChange() {
        [fiatCurrency
            .dropFirst(1)
            .observeNext { [weak self] in
                self?.data.fiatCurrency = $0
            },
         cryptoCurrency
            .dropFirst(1)
            .observeNext { [weak self] in
                self?.data.cryptoCurrency = $0
            },
         blockExplorer
            .dropFirst(1)
            .observeNext { [weak self] in
                self?.data.blockExplorer = $0
            },
         onChainRequestAddressType
            .dropFirst(1)
            .observeNext { [weak self] in
                self?.data.onChainRequestAddressType = $0
            },
         lightningRequestExpiry
            .dropFirst(1)
            .observeNext { [weak self] in
                self?.data.lightningRequestExpiry = $0
            },
         paymentsPINProtection
            .dropFirst(1)
            .observeNext { [weak self] in
                self?.data.paymentsPINProtection = $0
            }
        ].dispose(in: reactive.bag)
    }

    func updateCurrency(_ currency: Currency) {
        if let currency = currency as? Bitcoin {
            cryptoCurrency.value = currency
        } else if let currency = currency as? FiatCurrency {
            fiatCurrency.value = currency
        }

        if type(of: primaryCurrency.value) == type(of: currency) {
            primaryCurrency.value = currency
        } else {
            secondaryCurrency.value = currency
        }
    }

    func swapCurrencies() {
        let primary = primaryCurrency.value
        primaryCurrency.value = secondaryCurrency.value
        secondaryCurrency.value = primary

        data.isFiatCurrencyPrimary = primaryCurrency.value is FiatCurrency
    }
}
