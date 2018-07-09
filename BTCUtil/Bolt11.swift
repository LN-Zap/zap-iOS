//
//  BTCUtil
//
//  Created by Otto Suess on 09.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct Bolt11 {
    struct Invoice: Equatable {
        var network: Network?
        var date: Date?
        var amount: Satoshi?
        var description: String?
        var expiry: TimeInterval?
    }
    
    enum Prefix: String {
        case lnbc
        case lntb
        case lnbcrt
        
        static func forNetwork(_ network: Network) -> Prefix {
            switch network {
            case .testnet:
                return .lntb
            case .mainnet:
                return .lnbc
            }
        }
    }
    
    enum Multiplier: Character {
        case milli = "m"
        case micro = "u"
        case nano = "n"
        case pico = "p"
        
        var value: NSDecimalNumber {
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
    
    enum FieldTypes: UInt8 {
        case fieldTypeP = 1     // fieldTypeP is the field containing the payment hash.
        case fieldTypeD = 13    // fieldTypeD contains a short description of the payment.
        case fieldTypeN = 19    // fieldTypeN contains the pubkey of the target node.
        case fieldTypeH = 23    // fieldTypeH contains the hash of a description of the payment.
        case fieldTypeX = 6     // fieldTypeX contains the expiry in seconds of the invoice.
        case fieldTypeF = 9     // fieldTypeF contains a fallback on-chain address.
        case fieldTypeR = 3     // fieldTypeR contains extra routing information.
        case fieldTypeC = 24    // fieldTypeC contains an optional requested final CLTV delta.
    }
    
    let signatureBase32Len = 104
    let timestampBase32Len = 7
    
    let network: Network
    
    init(network: Network) {
        self.network = network
    }
    
    func decode(string: String) -> Invoice? {
        var invoice: Invoice = Invoice()

        guard let (humanReadablePart, data) = Bech32.decode(string, limit: false) else { return nil }

        if humanReadablePart.count < 3 {
            return nil
        }
        
        if !humanReadablePart.starts(with: Prefix.forNetwork(network).rawValue) {
            return nil
        }
        invoice.network = network
        invoice.amount = decodeAmount(for: humanReadablePart)
        
        let invoiceData = data.dropLast(signatureBase32Len)
        
        if invoiceData.count < timestampBase32Len {
            return nil
        }
        
        invoice = parseTimestamp(data: invoiceData[invoiceData.startIndex..<invoiceData.startIndex + timestampBase32Len], invoice: invoice)
        
        let tagData = invoiceData[invoiceData.startIndex + timestampBase32Len..<invoiceData.endIndex]
        return parseTaggedFields(data: tagData, invoice: invoice)
    }
    
    private func parseTimestamp(data: Data, invoice: Invoice) -> Invoice {
        var invoice = invoice
        invoice.date = Date(timeIntervalSince1970: TimeInterval(base32ToUInt(data)))
        return invoice
    }
    
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
                // TODO: parse the other stuff too.
                case .fieldTypeP:
                    break //parsePaymentHash(base32Data)
                case .fieldTypeD:
                    guard invoice.description == nil else { break }
                    invoice.description = parseDescription(data: base32Data)
                case .fieldTypeN:
                    break //parseDestination(base32Data)
                case .fieldTypeH:
                    break //parseDescriptionHash(base32Data)
                case .fieldTypeX:
                    guard invoice.expiry == nil else { break }
                    invoice.expiry = parseExpiry(data: base32Data)
                case .fieldTypeF:
                    break //parseFallbackAddr(base32Data, net)
                case .fieldTypeR:
                    break //parseRouteHint(base32Data)
                case .fieldTypeC:
                    break //parseMinFinalCLTVExpiry(base32Data)
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
        guard let base256Data = SegwitAddress.convertBits(data: data, fromBits: 5, toBits: 8, pad: false) else { return nil }
        return String(data: base256Data, encoding: .utf8)
    }
    
    private func parseExpiry(data: Data) -> TimeInterval {
        return TimeInterval(base32ToUInt(data))
    }
    
    private func decodeAmount(for humanReadablePart: String) -> Satoshi? {
        let netPrefixLength = Prefix.forNetwork(network).rawValue.count
        var amountString = humanReadablePart[humanReadablePart.index(humanReadablePart.startIndex, offsetBy: netPrefixLength)..<humanReadablePart.endIndex]
        
        guard amountString.count >= 2 else { return nil }

        let lastCharacter = amountString.removeLast()

        guard
            let multiplier = Multiplier(rawValue: lastCharacter),
            let amount = Int(amountString)
            else { return nil }
        
        return NSDecimalNumber(value: amount) * multiplier.value
    }
}
