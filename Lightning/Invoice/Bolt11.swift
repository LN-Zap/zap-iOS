//
//  Lightning
//
//  Created by Otto Suess on 09.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension Bolt11.Invoice {
    init(network: Network, date: Date) {
        self.network = network
        self.date = date
    }
}

struct Bolt11 {
    struct Invoice: Equatable {
        var network: Network
        var date: Date
        var paymentHash: Data?
        var amount: Satoshi?
        var description: String?
        var expiry: TimeInterval?
        var fallbackAddress: BitcoinAddress?
    }

    private enum Prefix: String {
        case lnbc
        case lntb
        case lnbcrt

        static func forNetwork(_ network: Network) -> Prefix {
            switch network {
            case .regtest:
                return .lnbcrt
            case .testnet:
                return .lntb
            case .mainnet:
                return .lnbc
            }
        }
    }

    private enum Multiplier: Character {
        case milli = "m"
        case micro = "u"
        case nano = "n"
        case pico = "p"

        var value: Decimal {
            switch self {
            case .milli:
                return 100000
            case .micro:
                return 100
            case .nano:
                return 0.1
            case .pico:
                return 0.0001
            }
        }
    }

    private enum FieldTypes: UInt8 {
        case fieldTypeP = 1  // fieldTypeP is the field containing the payment hash.
        case fieldTypeD = 13 // fieldTypeD contains a short description of the payment.
        case fieldTypeN = 19 // fieldTypeN contains the pubkey of the target node.
        case fieldTypeH = 23 // fieldTypeH contains the hash of a description of the payment.
        case fieldTypeX = 6  // fieldTypeX contains the expiry in seconds of the invoice.
        case fieldTypeF = 9  // fieldTypeF contains a fallback on-chain address.
        case fieldTypeR = 3  // fieldTypeR contains extra routing information.
        case fieldTypeC = 24 // fieldTypeC contains an optional requested final CLTV delta.
    }

    private let signatureBase32Len = 104
    private let timestampBase32Len = 7
    private let hashBase32Len = 52

    func decode(string: String) -> Invoice? {
        guard
            let (humanReadablePart, data) = Bech32.decode(string, limit: false),
            humanReadablePart.count > 3,
            let network = decodeNetwork(humanReadablePart: humanReadablePart) else { return nil }

        let invoiceData = data.dropLast(signatureBase32Len)

        guard invoiceData.count >= timestampBase32Len else { return nil }

        let date = parseTimestamp(data: invoiceData[invoiceData.startIndex..<invoiceData.startIndex + timestampBase32Len])
        var invoice = Invoice(network: network, date: date)

        invoice.amount = decodeAmount(for: humanReadablePart, network: network)

        let tagData = invoiceData[invoiceData.startIndex + timestampBase32Len..<invoiceData.endIndex]
        return parseTaggedFields(data: tagData, invoice: invoice)
    }

    private func parseTimestamp(data: Data) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(base32ToUInt(data)))
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func parseTaggedFields(data: Data, invoice: Invoice) -> Invoice? {
        var invoice = invoice
        var index: Data.Index = data.startIndex
        while data.endIndex - index >= 3 {
            let type = FieldTypes(rawValue: data[index])

            guard
                let dataLength = parseFieldDataLength(data[index + 1..<index + 3]),
                data.endIndex >= index + 3 + dataLength
                else { return nil }

            let base32Data = data[index + 3..<index + 3 + dataLength]

            index += 3 + dataLength

            if let type = type {
                switch type {
                case .fieldTypeP:
                    guard invoice.paymentHash == nil else { break }
                    invoice.paymentHash = parsePaymentHash(data: base32Data)
                case .fieldTypeD:
                    guard invoice.description == nil else { break }
                    invoice.description = parseDescription(data: base32Data)
                case .fieldTypeX:
                    guard invoice.expiry == nil else { break }
                    invoice.expiry = parseExpiry(data: base32Data)
                case .fieldTypeF:
                    guard invoice.fallbackAddress == nil else { break }
                    invoice.fallbackAddress = parseFallbackAddress(data: base32Data, network: invoice.network)
                case .fieldTypeN, .fieldTypeH, .fieldTypeC, .fieldTypeR:
                    break
                }
            }
        }

        return invoice
    }

    private func base32ToUInt(_ data: Data) -> UInt {
        var result: UInt = 0
        for byte in data {
            result = result << 5 | UInt(byte)
        }
        return result
    }

    private func parseFieldDataLength(_ data: Data) -> Int? {
        guard data.count == 2 else { return nil }
        return Int(data[data.startIndex]) << 5 | Int(data[data.startIndex + 1])
    }

    private func parseDescription(data: Data) -> String? {
        guard let base256Data = data.convertBits(fromBits: 5, toBits: 8, pad: false) else { return nil }
        return String(data: base256Data, encoding: .utf8)
    }

    private func parseExpiry(data: Data) -> TimeInterval {
        return TimeInterval(base32ToUInt(data))
    }

    private func parsePaymentHash(data: Data) -> Data? {
        guard data.count == hashBase32Len else { return nil }
        return data.convertBits(fromBits: 5, toBits: 8, pad: false)
    }

    private func parseFallbackAddress(data: Data, network: Network) -> BitcoinAddress? {
        guard data.count >= 2 else { return nil }
        let version = data[data.startIndex]
        guard let data = data[(data.startIndex + 1)...].convertBits(fromBits: 5, toBits: 8, pad: false) else { return nil }

        switch version {
        case 0:
            if data.count == 20 {
                return BitcoinAddress(witnessPubKeyHash: data, network: network)
            } else if data.count == 32 {
                return BitcoinAddress(witnessScriptHash: data, network: network)
            } else {
                return nil
            }
        case 17:
            return BitcoinAddress(pubKeyHash: data, network: network)
        case 18:
            return BitcoinAddress(scriptHashFromHash: data, network: network)
        default:
            return nil
        }
    }

    private func decodeAmount(for humanReadablePart: String, network: Network) -> Satoshi? {
        let netPrefixLength = Prefix.forNetwork(network).rawValue.count
        var amountString = humanReadablePart[humanReadablePart.index(humanReadablePart.startIndex, offsetBy: netPrefixLength)..<humanReadablePart.endIndex]

        guard amountString.count >= 2 else { return nil }

        let lastCharacter = amountString.removeLast()

        guard
            let multiplier = Multiplier(rawValue: lastCharacter),
            let amount = Int(amountString)
            else { return nil }

        return Decimal(amount) * multiplier.value
    }

    private func decodeNetwork(humanReadablePart: String) -> Network? {
        if humanReadablePart.starts(with: Prefix.forNetwork(.mainnet).rawValue) {
            return .mainnet
        } else if humanReadablePart.starts(with: Prefix.forNetwork(.testnet).rawValue) {
            return .testnet
        }
        return nil
    }
}
