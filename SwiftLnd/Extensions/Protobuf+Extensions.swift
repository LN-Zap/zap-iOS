//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import LndRpc
import SwiftBTC

extension LNDInvoice {
    convenience init(amount: Satoshi?, memo: String?) {
        self.init()
        if let memo = memo {
            self.memo = memo
        }
        if let amount = amount {
            value = Int64(truncating: amount as NSDecimalNumber)
        }
        private_p = true
    }
}

extension LNDNodeInfoRequest {
    convenience init(pubKey: String) {
        self.init()
        
        self.pubKey = pubKey
    }
}

extension LNDPayReqString {
    convenience init(payReq: String) {
        self.init()
        
        self.payReq = payReq
    }
}

extension LNDNewAddressRequest {
    convenience init(type: OnChainRequestAddressType) {
        self.init()
        
        switch type {
        case .witnessPubkeyHash:
            self.type = .witnessPubkeyHash
        case .nestedPubkeyHash:
            self.type = .nestedPubkeyHash
        }
    }
}

extension LNDConnectPeerRequest {
    convenience init(pubKey: String, host: String) {
        self.init()

        addr = LNDLightningAddress()
        addr.pubkey = pubKey
        addr.host = host
    }
}

extension LNDOpenChannelRequest {
    convenience init(pubKey: String, amount: Satoshi) {
        self.init()

        if let pubKey = Data(hexadecimalString: pubKey) {
            nodePubkey = pubKey
        }
        nodePubkeyString = pubKey
        localFundingAmount = Int64(truncating: amount as NSDecimalNumber)
        private_p = true
    }
}

extension LNDSendCoinsRequest {
    convenience init(address: BitcoinAddress, amount: Satoshi) {
        self.init()

        self.addr = address.string
        self.amount = Int64(truncating: amount as NSDecimalNumber)
    }
}

extension LNDSendRequest {
    convenience init(paymentRequest: String, amount: Satoshi?) {
        self.init()

        self.paymentRequest = paymentRequest
        if let amount = amount {
            self.amt = Int64(truncating: amount as NSDecimalNumber)
        }
    }
}

extension LNDCloseChannelRequest {
    convenience init?(channelPoint: ChannelPoint, force: Bool) {
        self.init()

        self.channelPoint = LNDChannelPoint()
        self.channelPoint.outputIndex = UInt32(channelPoint.outputIndex)
        if let fundingTxidBytes = Data(hexadecimalString: channelPoint.fundingTxid.hexEndianSwap()) {
            self.channelPoint.fundingTxidBytes = fundingTxidBytes
        }
        self.force = force
    }
}

extension LNDQueryRoutesRequest {
    convenience init(destination: String, amount: Satoshi) {
        self.init()

        pubKey = destination
        amt = Int64(truncating: amount as NSDecimalNumber)
        numRoutes = 10
    }
}

// MARK: - Wallet

extension LNDGenSeedRequest {
    convenience init(passphrase: String?) {
        self.init()

        if let passphrase = passphrase?.data(using: .utf8) {
            self.aezeedPassphrase = passphrase
        }
    }
}

extension LNDInitWalletRequest {
    convenience init(password: String, mnemonic: [String]) {
        self.init()

        if let passwordData = password.data(using: .utf8) {
            self.walletPassword = passwordData
        }
        self.cipherSeedMnemonicArray = NSMutableArray(array: mnemonic)
    }
}

extension LNDUnlockWalletRequest {
    convenience init(password: String) {
        self.init()

        if let passwordData = password.data(using: .utf8) {
            self.walletPassword = passwordData
        }
    }
}
