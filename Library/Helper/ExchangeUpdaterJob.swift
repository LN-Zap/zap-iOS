//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import Lightning
import Logger
import SwiftBTC

final class ExchangeUpdaterJob {
    private static var timer: Timer?

    static func start() {
        let job = ExchangeUpdaterJob()
        timer = Timer.scheduledTimer(withTimeInterval: 60 * 10, repeats: true) { _ in
            job.run()
        }
        timer?.fire()
    }

    static func stop() {
        timer?.invalidate()
        timer = nil
    }

    func run() {
        ExchangeRateLoader().load { ExchangeData.blockchainInfoCurrencies = $0.value }
        ExchangeRateLoader().loadTicker(ticker: "NOK", symbol: "kr", completion: { ExchangeData.currencies["NOK"] = $0.value })
        ExchangeRateLoader().loadTicker(ticker: "USD", symbol: "$", completion: { ExchangeData.currencies["USD"] = $0.value })
    }
}

enum ExchangeData {
    static var currencies: [String: FiatCurrency] = [:] {
        didSet {
            availableCurrencies = Array(currencies.values)
        }
    }

    static var blockchainInfoCurrencies: [FiatCurrency]? = [] {
        didSet {
            blockchainInfoCurrencies?.forEach{ currencies[$0.currencyCode] = $0}
        }
    }

    static var availableCurrencies: [FiatCurrency]? {
        didSet {
            guard let availableCurrencies = availableCurrencies else { return }

            let currentFiatCurrencyCode = Settings.shared.fiatCurrency.value.currencyCode
            if let updatedCurrency = availableCurrencies.first(where: { $0.currencyCode == currentFiatCurrencyCode }) {
                Settings.shared.updateCurrency(updatedCurrency)
            }

            Logger.info("did update exchange rates")
        }
    }
}
