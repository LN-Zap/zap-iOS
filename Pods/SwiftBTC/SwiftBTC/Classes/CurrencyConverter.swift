//
//  SatoshiConverter.swift
//  BigInt
//
//  Created by Otto Suess on 08.02.19.
//

import Foundation

public enum CurrencyConverter {
    public static func convert(amount: Decimal, from: Currency, to: Currency) -> Decimal {
        return amount / from.exchangeRate * to.exchangeRate
    }
}
