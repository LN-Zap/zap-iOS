//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension Info {
    // swiftlint:disable type_name
    enum template {
        static var testnet: Info {
            return Info(
                alias: "test",
                blockHeight: 124,
                isSyncedToChain: true,
                network: .testnet,
                pubKey: "",
                activeChannelCount: 2,
                bestHeaderDate: Date()
            )
        }
        
        static var mainnet: Info {
            return Info(
                alias: "test",
                blockHeight: 124,
                isSyncedToChain: true,
                network: .mainnet,
                pubKey: "",
                activeChannelCount: 2,
                bestHeaderDate: Date()
            )
        }
    }
}

extension OnChainConfirmedTransaction {
    static var template: OnChainConfirmedTransaction {
        return OnChainConfirmedTransaction(
            id: "100",
            amount: 21005000,
            date: Date(),
            fees: 12,
            confirmations: 14,
            destinationAddress: "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7"
        )
    }
}

extension OnChainUnconfirmedTransaction {
    static var template: OnChainUnconfirmedTransaction {
        return OnChainUnconfirmedTransaction(id: "abc", amount: 1000, date: Date(), destinationAddress: "asdfghjkllkjhgfdsasdfghjkljsasdfghjk")
    }
}

extension LightningPayment {
    static var template: LightningPayment {
        return LightningPayment(
            id: "id31234567896543",
            amount: 1645,
            date: Date(),
            fees: 12,
            paymentHash: "paymentHash"
        )
    }
}

extension Channel {
    static var template: Channel {
        return Channel(
            blockHeight: 1,
            state: .active,
            localBalance: 100,
            remoteBalance: 100,
            remotePubKey: "abc",
            capacity: 200,
            updateCount: 0,
            channelPoint: ChannelPoint.template,
            csvDelay: 10)
    }
}

extension ChannelPoint {
    static var template: ChannelPoint {
        return ChannelPoint(string: "abc:123")
    }
}

extension PaymentRequest {
    static var template: PaymentRequest {
        return PaymentRequest(paymentHash: "444663acd9833c2a05ba0a481a8800f97e0ae12066eadd65993edcbcbdbee11b", destination: " 03e50492eab4107a773141bb419e107bda3de3d55652e6e1a41225f06a0bbf2d56", amount: 150000, memo: "Read: Opinion Editorial: Crypto Wolves", date: Date(), expiryDate: Date().addingTimeInterval(3600), raw: "lntb1500n1pdhdgqjpp5g3rx8txesv7z5pd6pfyp4zqql9lq4cfqvm4d6eve8mwte0d7uydsdpa2fjkzep6yp8hq6twd9hkugz9v35hgmmjd9skcw3qgde8jur5dus9wmmvwejhxcqzysqwez4c6m2070ltq2mfz3ffc5chvwwq6q7tec2pmauths5wpng8ny24aq8gqtuj4w9jmprqt4y50ux27222nkmqfmlkulfr2h6swuqrgpj3ekm4")
    }
}
