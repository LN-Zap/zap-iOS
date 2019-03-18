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
        DispatchQueue.global(qos: .background).async {
            let apiCallGroup = DispatchGroup()
            var blockchaininfo: [FiatCurrency] = []
            var bitcoinaverage: [FiatCurrency] = []

            apiCallGroup.enter()
            ExchangeRateLoader().load {
                if let blockchaininfoResponse = $0.value {
                    blockchaininfo = blockchaininfoResponse
                }
                apiCallGroup.leave()
            }

            apiCallGroup.enter()
            ExchangeRateLoader().loadTicker {
                if let bitcoinaverageResponse = $0.value {
                    bitcoinaverage = bitcoinaverageResponse
                }
                apiCallGroup.leave()
            }

            apiCallGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem {
                var result: [String: FiatCurrency] = [:]
                blockchaininfo.forEach { result[$0.currencyCode] = $0 }
                bitcoinaverage.forEach { result[$0.currencyCode] = $0 }
                ExchangeData.availableCurrencies = Array(result.values)
            })
        }
    }
}

enum ExchangeData {
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
