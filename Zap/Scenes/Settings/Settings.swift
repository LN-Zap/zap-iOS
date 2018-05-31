//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

enum Settings {
    static var fiatCurrency = Observable<FiatCurrency>(FiatCurrency(currencyCode: "USD", symbol: "$", localized: "US Dollar", exchangeRate: 7076.3512))
    static var cryptoCurrency = Observable<Bitcoin>(Bitcoin(unit: .bit))
    
    static var primaryCurrency = Observable<Currency>(Settings.cryptoCurrency.value)
    static var secondaryCurrency = Observable<Currency>(Settings.fiatCurrency.value)

    static var blockExplorer = BlockExplorer.blockchainInfo
    
    static var onChainRequestAddressType = Observable<OnChainRequestAddressType>(.nestedPubkeyHash)
    
    static func updateCurrency(_ currency: Currency) {
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
    
    static func swapCurrencies() {
        let primary = Settings.primaryCurrency.value
        Settings.primaryCurrency.value = Settings.secondaryCurrency.value
        Settings.secondaryCurrency.value = primary
    }
}
