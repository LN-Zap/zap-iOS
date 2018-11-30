//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension Lnrpc_Invoice {
    init(amount: Satoshi?, memo: String?) {
        self.init()
        if let memo = memo {
            self.memo = memo
        }
        if let amount = amount {
            value = Int64(truncating: amount as NSDecimalNumber)
        }
        self.private = true
    }
}

extension Lnrpc_NodeInfoRequest {
    init(pubKey: String) {
        self.pubKey = pubKey
    }
}

extension Lnrpc_PayReqString {
    init(payReq: String) {
        self.payReq = payReq
    }
}

extension Lnrpc_NewAddressRequest {
    init(type: OnChainRequestAddressType) {
        switch type {
        case .witnessPubkeyHash:
            self.type = .witnessPubkeyHash
        case .nestedPubkeyHash:
            self.type = .nestedPubkeyHash
        }
    }
}

extension Lnrpc_ConnectPeerRequest {
    init(pubKey: String, host: String) {
        addr = Lnrpc_LightningAddress()
        addr.pubkey = pubKey
        addr.host = host
    }
}

extension Lnrpc_OpenChannelRequest {
    init(pubKey: String, amount: Satoshi) {
        if let pubKey = Data(hexadecimalString: pubKey) {
            nodePubkey = pubKey
        }
        nodePubkeyString = pubKey
        localFundingAmount = Int64(truncating: amount as NSDecimalNumber)
        `private` = true
    }
}

extension Lnrpc_SendCoinsRequest {
    init(address: BitcoinAddress, amount: Satoshi) {
        self.addr = address.string
        self.amount = Int64(truncating: amount as NSDecimalNumber)
    }
}

extension Lnrpc_SendRequest {
    init(paymentRequest: String, amount: Satoshi?, maxFee: Satoshi?) {
        self.paymentRequest = paymentRequest
        if let amount = amount {
            self.amt = Int64(truncating: amount as NSDecimalNumber)
        }
        if let maxFee = maxFee {
            self.feeLimit = Lnrpc_FeeLimit()
            self.feeLimit.fixed = Int64(truncating: maxFee as NSDecimalNumber)
        }
    }
}

extension Lnrpc_CloseChannelRequest {
    init?(channelPoint: ChannelPoint, force: Bool) {
        self.channelPoint = Lnrpc_ChannelPoint()
        self.channelPoint.outputIndex = UInt32(channelPoint.outputIndex)
        if let fundingTxidBytes = Data(hexadecimalString: channelPoint.fundingTxid.hexEndianSwap()) {
            self.channelPoint.fundingTxidBytes = fundingTxidBytes
        }
        self.force = force
    }
}

extension Lnrpc_QueryRoutesRequest {
    init(destination: String, amount: Satoshi) {
        pubKey = destination
        amt = Int64(truncating: amount as NSDecimalNumber)
        numRoutes = 10
    }
}

// MARK: - Wallet

extension Lnrpc_GenSeedRequest {
    init(passphrase: String?) {
        if let passphrase = passphrase?.data(using: .utf8) {
            self.aezeedPassphrase = passphrase
        }
    }
}

extension Lnrpc_InitWalletRequest {
    init(password: String, mnemonic: [String]) {
        if let passwordData = password.data(using: .utf8) {
            self.walletPassword = passwordData
        }
        self.cipherSeedMnemonic = mnemonic
    }
}

extension Lnrpc_UnlockWalletRequest {
    init(password: String) {
        if let passwordData = password.data(using: .utf8) {
            self.walletPassword = passwordData
        }
    }
}
