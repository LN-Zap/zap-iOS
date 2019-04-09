//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension Invoice {
    enum Template {
        static func create(memo: String, amount: Satoshi, date: Date) -> Invoice {
            return Invoice(
                id: "l1",
                memo: memo,
                amount: amount,
                state: .settled,
                date: date,
                settleDate: Date(),
                expiry: Date(),
                paymentRequest: "abc"
            )
        }
    }
}

extension Info {
    enum Template {
        static var testnet: Info {
            return Info(
                alias: "test",
                blockHeight: 124123,
                isSyncedToChain: true,
                network: .testnet,
                pubKey: "123123",
                activeChannelCount: 2,
                bestHeaderDate: Date(),
                uris: [],
                version: Version(string: "0.4.2-beta commit=625b210f441ece841c76b81377dd96e8d09aba8e")
            )
        }

        static var mainnet: Info {
            return Info(
                alias: "Zap Node",
                blockHeight: 124,
                isSyncedToChain: true,
                network: .mainnet,
                pubKey: "",
                activeChannelCount: 2,
                bestHeaderDate: Date(),
                uris: [],
                version: Version(string: "0.4.2-beta commit=625b210f441ece841c76b81377dd96e8d09aba8e")
            )
        }
    }
}

extension BitcoinAddress {
    static var template: BitcoinAddress {
        // swiftlint:disable:next force_unwrapping
        return BitcoinAddress(string: "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7")!
    }
}

extension Transaction {
    enum Template {
        static var `default` = create(id: "1", amount: 1000000, date: Date())

        static func create(id: String, amount: Satoshi, date: Date) -> Transaction {
            return Transaction(
                id: id,
                amount: amount,
                date: date,
                fees: 12400,
                destinationAddresses: [BitcoinAddress.template],
                blockHeight: 10
            )
        }
    }

}

extension Payment {
    enum Template {
        static var `default` = create(id: "l1", amount: 1645, date: Date(), destination: "abc")

        static func create(id: String, amount: Satoshi, date: Date, destination: String) -> Payment {
            return Payment(
                id: id,
                amount: amount,
                date: date,
                fees: 12,
                paymentHash: id,
                destination: destination
            )
        }
    }
}

extension Channel {
    enum Template {
        static let `defalut` = create(state: .active, localBalance: 100, remoteBalance: 100, remotePubKey: "abc")

        static func create(state: Channel.State, localBalance: Satoshi, remoteBalance: Satoshi, remotePubKey: String) -> Channel {
            return Channel(blockHeight: 50, state: state, localBalance: localBalance, remoteBalance: remoteBalance, remotePubKey: remotePubKey, capacity: localBalance + remoteBalance, updateCount: 1, channelPoint: ChannelPoint.template, csvDelay: 10)
        }
    }
}

extension ChannelPoint {
    static var template: ChannelPoint {
        return ChannelPoint(string: "t1:123")
    }
}

extension PaymentRequest {
    enum Template {
        static var testnet: PaymentRequest {
        return PaymentRequest(paymentHash: "444663acd9833c2a05ba0a481a8800f97e0ae12066eadd65993edcbcbdbee11b", destination: " 03e50492eab4107a773141bb419e107bda3de3d55652e6e1a41225f06a0bbf2d56", amount: 150000, memo: "Read: Opinion Editorial: Crypto Wolves", date: Date(), expiryDate: Date().addingTimeInterval(3600), raw: "lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4", fallbackAddress: nil, network: .testnet)
        }

        static var testnetFallback: PaymentRequest {
            return PaymentRequest(paymentHash: "444663acd9833c2a05ba0a481a8800f97e0ae12066eadd65993edcbcbdbee11b", destination: " 03e50492eab4107a773141bb419e107bda3de3d55652e6e1a41225f06a0bbf2d56", amount: 150000, memo: "Read: Opinion Editorial: Crypto Wolves", date: Date(), expiryDate: Date().addingTimeInterval(3600), raw: "lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4", fallbackAddress: BitcoinAddress(string: "mzMD4CTKR6Essspredb5MSBPECtJrnVgBC"), network: .testnet)
        }
    }
}
