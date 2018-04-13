//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension Info {
    static var template: Info {
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
}

extension BlockchainTransaction {
    static var template: BlockchainTransaction {
        return BlockchainTransaction(
            id: "id123456",
            amount: 178,
            date: Date(),
            fees: 12,
            confirmations: 14,
            firstDestinationAddress: "firstDestinationAddress"
        )
    }
}

extension Payment {
    static var template: Payment {
        return Payment(
            id: "id31234567896543",
            amount: 1645,
            date: Date(),
            fees: 12,
            paymentHash: "paymentHash"
        )
    }
}
