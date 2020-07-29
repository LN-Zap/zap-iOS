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
        DispatchQueue.global(qos: .background).async {
            self.fetchCurrencyData(
                url: "https://blockchain.info/ticker",
                parse: ExchangeRateLoader.parseBlockchainInfoData,
                completion: {
                    if let blockchaininfoResponse = try? $0.get() {
                        var result: [String: FiatCurrency] = [:]
                        blockchaininfoResponse.forEach { result[$0.currencyCode] = $0 }
                        completion(.success(Array(result.values)))
                    }
                }
            )
        }}

    func fetchCurrencyData(url: String, parse: @escaping (String, Any) -> FiatCurrency?, completion: @escaping (Result<[FiatCurrency], ExchangeRateLoaderError>) -> Void) {
        guard let url = URL(string: url) else { fatalError("Invalid ticker url.") }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                Logger.error(error.localizedDescription)
                completion(.failure(.loadingError))
            } else if
                    let data = data,
                    let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
                    let json = jsonData as? [String: Any] {
                    let currencies = json.compactMap { parse($0, $1) }
                completion(.success(currencies))
            }
        }
        task.resume()
    }

    private static func parseBlockchainInfoData(for currencyCode: String, data: Any) -> FiatCurrency? {
        guard
            let localized = Locale.autoupdatingCurrent.localizedString(forCurrencyCode: currencyCode),
            let data = data as? [String: Any],
            let symbol = data["symbol"] as? String,
            let valueNumber = data["15m"] as? NSNumber
            else { return nil }
        let exchangeRate = valueNumber.decimalValue

        return FiatCurrency(currencyCode: currencyCode, symbol: symbol, localized: localized, exchangeRate: exchangeRate)
    }

    private static let currencySymbols = ["TND": "د.ت.‏", "JPY": "¥", "MNT": "₮", "CHF": "CHF", "TWD": "$", "GMD": "D", "VND": "₫", "FKP": "£", "CNY": "¥", "CZK": "Kč", "BGN": "лв.", "IRR": "IRR", "ILS": "₪", "SBD": "$", "MYR": "RM", "CAD": "$", "KES": "Ksh", "ISK": "ISK", "PKR": "Rs", "ERN": "Nfk", "OMR": "ر.ع.‏", "NPR": "नेरू", "MOP": "MOP$", "MUR": "Rs", "CUP": "$", "MKD": "den", "SLL": "Le", "AOA": "Kz", "DOP": "RD$", "EUR": "€", "XOF": "CFA", "BTN": "Nu.", "AFN": "؋", "GNF": "FG", "BOB": "Bs", "MRU": "UM", "AMD": "֏", "PAB": "B/.", "HKD": "HK$", "HRK": "HRK", "BYN": "Br", "BIF": "FBu", "PYG": "Gs.", "LKR": "Rs.", "BDT": "৳", "KRW": "₩", "YER": "ر.ي.‏", "HNL": "L", "BND": "$", "SDG": "SDG", "BHD": "د.ب.‏", "ARS": "$", "TMT": "TMT", "MVR": "MVR", "ZMW": "K", "SEK": "kr", "GTQ": "Q", "GBP": "£", "ALL": "Lekë", "GYD": "$", "MDL": "L", "COP": "$", "KYD": "$", "AUD": "$", "TRY": "₺", "UZS": "soʻm", "BAM": "KM", "ANG": "NAf.", "BWP": "P", "JOD": "د.أ.‏", "DZD": "د.ج.‏", "LAK": "₭", "LYD": "د.ل.‏", "JMD": "$", "KGS": "сом", "KHR": "៛", "SOS": "S", "PLN": "PLN", "UYU": "$", "TJS": "сом.", "CVE": "​", "UGX": "USh", "KWD": "د.ك.‏", "TZS": "TSh", "NZD": "$", "SAR": "SAR", "BSD": "BSD", "IDR": "Rp", "SRD": "$", "NAD": "$", "KMF": "CF", "MWK": "MK", "IQD": "د.ع.‏", "XAF": "FCFA", "TTD": "$", "GHS": "GH₵", "STN": "Db", "LBP": "ل.ل.‏", "SCR": "SR", "THB": "THB", "ETB": "Br", "CDF": "FC", "BRL": "R$", "PEN": "S/", "RWF": "RF", "DJF": "Fdj", "KPW": "KPW", "BBD": "$", "PGK": "K", "HUF": "HUF", "VEF": "Bs.", "KZT": "₸", "AED": "د.إ.‏", "MXN": "$", "HTG": "G", "BZD": "$", "WST": "WS$", "SSP": "£", "PHP": "₱", "INR": "₹", "RSD": "RSD", "SGD": "$", "GEL": "₾", "LRD": "$", "USD": "$", "NGN": "₦", "XPF": "FCFP", "CLP": "$", "BMD": "BMD", "RON": "RON", "VUV": "VT", "DKK": "kr.", "MAD": "MAD", "AWG": "Afl.", "GIP": "£", "NOK": "kr", "FJD": "$", "EGP": "ج.م.‏", "ZAR": "R", "UAH": "₴", "QAR": "ر.ق.‏", "NIO": "C$", "SZL": "E", "TOP": "T$", "RUB": "RUB", "XCD": "XCD", "AZN": "₼", "MZN": "MTn", "MMK": "K", "MGA": "Ar", "CRC": "₡", "SHP": "£", "SYP": "ل.س.‏"]
}
