//
//  Lightning
//
//  Created by 0 on 01.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger
import SwiftBTC
import SwiftLnd

public final class ExchangeRateLoader {

    public enum ExchangeRateLoaderError: Error {
        case loadingError
    }

    public init() {}

    public func load(completion: @escaping (Result<[FiatCurrency], ExchangeRateLoaderError>) -> Void) {
        guard let url = URL(string: "https://blockchain.info/ticker") else { fatalError("Invalid ticker url.") }
        let task = URLSession.pinned.dataTask(with: url) { data, _, error in
            if let error = error {
                Logger.error(error.localizedDescription)
                completion(.failure(.loadingError))
            } else if let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = jsonData as? [String: Any] {
                let currencies = json.compactMap { ExchangeRateLoader.parseFiatCurrency(for: $0, data: $1) }
                completion(.success(currencies))
            }
        }
        task.resume()
    }

    public func loadTicker(ticker: String, symbol: String, completion: @escaping (Result<[FiatCurrency], ExchangeRateLoaderError>) -> Void) {
        guard let url = URL(string: "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC\(ticker)") else { fatalError("Invalid ticker url.") }

        let task = URLSession.pinned.dataTask(with: url) { data, _, error in
            if let error = error {
                Logger.error(error.localizedDescription)
                completion(.failure(.loadingError))
            } else if let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = jsonData as? [String: Any] {
                let currencies = [ExchangeRateLoader.parseTicker(for: ticker, symbol: symbol, data: json)].compactMap { $0 }
                completion(.success(currencies))
            }
        }
        task.resume()
    }

    private static func parseTicker(for ticker: String, symbol: String, data: Any) -> FiatCurrency? {
        guard
                let localized = Locale.autoupdatingCurrent.localizedString(forCurrencyCode: ticker),
                let data = data as? [String: Any],
                let averages = data["averages"] as? [String: Any],
                let valueNumber = averages["day"] as? NSNumber
                else { return nil }
        let exchangeRate = valueNumber.decimalValue

        return FiatCurrency(currencyCode: ticker, symbol: symbol, localized: localized, exchangeRate: exchangeRate)
    }

    private static func parseFiatCurrency(for currencyCode: String, data: Any) -> FiatCurrency? {
        guard
            let localized = Locale.autoupdatingCurrent.localizedString(forCurrencyCode: currencyCode),
            let data = data as? [String: Any],
            let symbol = data["symbol"] as? String,
            let valueNumber = data["15m"] as? NSNumber
            else { return nil }
        let exchangeRate = valueNumber.decimalValue

        return FiatCurrency(currencyCode: currencyCode, symbol: symbol, localized: localized, exchangeRate: exchangeRate)
    }
}
