//
//  Widget
//
//  Created by 0 on 01.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Lightning
import NotificationCenter
import SwiftBTC
import UIKit

extension UIColor {
    static let deepSeaBlue = UIColor(red: 0.137, green: 0.145, blue: 0.2, alpha: 1)
    static let lightningOrange = UIColor(red: 0.992, green: 0.596, blue: 0, alpha: 1)
}

struct WidgetData: Codable, Equatable {
    let satoshi: Decimal
    let fiat: Decimal
    let currencyCode: String

    private static let key = "widget_data_key"

    func save() {
        guard let encoded = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.setValue(encoded, forKey: WidgetData.key)
    }

    static func load() -> WidgetData? {
        guard let coded = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetData.self, from: coded)
    }
}

extension UIFont {
    static let numberFont = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
    static let labelFont = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .light)
}

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet private weak var topLeftBackground: UIView!
    @IBOutlet private weak var topLeftLabel: UILabel!
    @IBOutlet private weak var topRightBackground: UIView!
    @IBOutlet private weak var topRightLabel: UILabel!

    @IBOutlet private weak var bottomLeftBackground: UIView!
    @IBOutlet private weak var bottomLeftLabel: UILabel!
    @IBOutlet private weak var bottomRightBackground: UIView!
    @IBOutlet private weak var bottomRightLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        topLeftBackground.backgroundColor = .clear

        topRightBackground.layer.cornerRadius = 5
        topRightBackground.backgroundColor = .lightningOrange
        topRightLabel.textColor = .white

        bottomLeftBackground.backgroundColor = .clear

        bottomRightBackground.layer.cornerRadius = 5
        bottomRightBackground.backgroundColor = .deepSeaBlue
        bottomRightLabel.textColor = .white

        if let data = WidgetData.load() {
            updateUI(for: data)
        } else {
            updateUI(for: WidgetData(satoshi: 0, fiat: 0, currencyCode: Locale.current.currencyCode ?? "USD"))
        }

        preferredContentSize = CGSize(width: view.bounds.width, height: 110)
    }

    func getCurrency(from currencies: [FiatCurrency], code: String) -> FiatCurrency? {
        return currencies.first(where: { $0.currencyCode == code })
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        ExchangeRateLoader().load { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.update(currencies: currencies, completionHandler: completionHandler)
            case .failure:
                completionHandler(.failed)
            }
        }
    }

    private func update(currencies: [FiatCurrency], completionHandler: @escaping (NCUpdateResult) -> Void) {
        let currency: FiatCurrency

        if let currencyCode = Locale.current.currencyCode,
            let selectedCurrency = getCurrency(from: currencies, code: currencyCode) {
            currency = selectedCurrency
        } else if let fallbackUSDCurrency = getCurrency(from: currencies, code: "USD") {
            currency = fallbackUSDCurrency
        } else if let firstCurrency = currencies.first {
            currency = firstCurrency
        } else {
            completionHandler(.failed)
            return
        }

        let satoshis = CurrencyConverter.convert(amount: 0.01, from: currency, to: Bitcoin.satoshi).rounded()
        let fiat = CurrencyConverter.convert(amount: 10000, from: Bitcoin.satoshi, to: currency)

        let newData = WidgetData(satoshi: satoshis, fiat: fiat, currencyCode: currency.currencyCode)

        if WidgetData.load() != newData {
            newData.save()

            DispatchQueue.main.async { [weak self] in
                self?.updateUI(for: newData)
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
        }
    }

    private func updateUI(for data: WidgetData) {
        topLeftLabel.attributedText = attributedFiatLabel(number: 0.01, currencyCode: data.currencyCode)
        topRightLabel.attributedText = attributedSatoshisLabel(number: data.satoshi)

        bottomLeftLabel.attributedText = attributedSatoshisLabel(number: 10000)
        bottomRightLabel.attributedText = attributedFiatLabel(number: data.fiat, currencyCode: data.currencyCode)
    }

    func attributedFiatLabel(number: Decimal, currencyCode: String) -> NSAttributedString? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode
        numberFormatter.locale = Locale.current

        guard let numberString = numberFormatter.string(from: number as NSDecimalNumber) else { return nil }

        let attributedString = NSMutableAttributedString(string: numberString, attributes: [.font: UIFont.numberFont])

        let range = (numberString as NSString).range(of: numberFormatter.currencySymbol)
        attributedString.addAttributes([.font: UIFont.labelFont], range: range)

        return attributedString
    }

    func attributedSatoshisLabel(number: Decimal) -> NSAttributedString? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.usesGroupingSeparator = true

        guard let numberString = numberFormatter.string(from: number as NSDecimalNumber) else { return nil }

        let attributedString = NSMutableAttributedString(string: numberString, attributes: [.font: UIFont.numberFont])
        attributedString.append(NSAttributedString(string: " Satoshis", attributes: [.font: UIFont.labelFont]))

        return attributedString
    }
}
