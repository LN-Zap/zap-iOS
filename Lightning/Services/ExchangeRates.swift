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

    private static var currencySymbols = buildCurrencySymbols()

    private static func buildCurrencySymbols() -> [String: String] {
        let identifiers = Locale.availableIdentifiers
        let formatter = NumberFormatter()
        var map: [String: String] = [:]
        for identifier in identifiers {
            formatter.locale = Locale(identifier: identifier)
            guard
                    let code = formatter.currencyCode,
                    let symbol = formatter.currencySymbol
                    else { continue }
            map[code] = symbol
        }
        return map
    }

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

    public func loadTicker(completion: @escaping (Result<[FiatCurrency], ExchangeRateLoaderError>) -> Void) {
        guard let url = URL(string: "https://apiv2.bitcoinaverage.com/indices/global/ticker/short?crypto=BTC") else { fatalError("Invalid ticker url.") }

        let task = URLSession.pinned.dataTask(with: url) { data, _, error in
            if let error = error {
                Logger.error(error.localizedDescription)
                completion(.failure(.loadingError))
            } else if let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = jsonData as? [String: Any] {
                let currencies = json
						.compactMap { ExchangeRateLoader.parseTicker(for: $0, data: $1) }
				completion(.success(currencies))
            }
        }
        task.resume()
    }

    private static func parseTicker(for ticker: String, data: Any) -> FiatCurrency? {
        let index = ticker.index(ticker.startIndex, offsetBy: 3)
        let currencyCode: String = ticker.substring(from: index)
        guard
                let localized = Locale.autoupdatingCurrent.localizedString(forCurrencyCode: currencyCode),
                let data = data as? [String: Any],
                let valueNumber = data["last"] as? NSNumber
                else { return nil }
        let exchangeRate = valueNumber.decimalValue

        return FiatCurrency(currencyCode: currencyCode, symbol: ExchangeRateLoader.currencySymbols[currencyCode] ?? currencyCode, localized: localized, exchangeRate: exchangeRate)
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
