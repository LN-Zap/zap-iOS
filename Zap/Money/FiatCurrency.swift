//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

struct FiatCurrency: Currency, Equatable {
    let currencyCode: String
    let symbol: String
    let localized: String
    let exchangeRate: NSDecimalNumber
    
    private var currencyFormatter: NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.generatesDecimalNumbers = true
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.autoupdatingCurrent
        currencyFormatter.currencyCode = currencyCode
        return currencyFormatter
    }
    
    func format(_ satoshis: Satoshi) -> String? {
        let fiatValue = satoshis.convert(to: .bitcoin) * exchangeRate
        return currencyFormatter.string(from: fiatValue)
    }
    
    func satoshis(from string: String) -> Satoshi? {
        guard let fiatValue = currencyFormatter.number(from: string) as? NSDecimalNumber else { return nil }
        return Satoshi.from(value: fiatValue / exchangeRate, unit: .bitcoin)
    }
}
