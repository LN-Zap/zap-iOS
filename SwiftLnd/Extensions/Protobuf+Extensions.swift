//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension Lnrpc_Invoice {
    init(amount: Satoshi?, memo: String?, expiry: ExpiryTime?) {
        self.init()
        if let amount = amount {
            value = amount.int64
        }
        if let memo = memo {
            self.memo = memo
        }
        if let expiry = expiry {
            self.expiry = Int64(expiry.rawValue)
        }
        `private` = true
    }
}

extension Lnrpc_NodeInfoRequest {
    init(pubKey: String) {
        self.init()

        self.pubKey = pubKey
    }
}

extension Lnrpc_PayReqString {
    init(payReq: String) {
        self.init()

        self.payReq = payReq
    }
}

extension Lnrpc_NewAddressRequest {
    init(type: OnChainRequestAddressType) {
        self.init()

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
        self.init()

        addr = Lnrpc_LightningAddress()
        addr.pubkey = pubKey
        addr.host = host
    }
}

extension Lnrpc_OpenChannelRequest {
    init(pubKey: String, csvDelay: Int?, amount: Satoshi) {
        self.init()

        if let pubKey = Data(hexadecimalString: pubKey) {
            nodePubkey = pubKey
        }
        nodePubkeyString = pubKey
        localFundingAmount = amount.int64
        if let csvDelay = csvDelay {
            remoteCsvDelay = UInt32(csvDelay)
        }
        `private` = true
    }
}

extension Lnrpc_SendCoinsRequest {
    init(address: BitcoinAddress, amount: Satoshi, confirmationTarget: Int) {
        self.init()

        self.addr = address.string
        self.amount = amount.int64
        self.targetConf = Int32(confirmationTarget)
    }
}

extension Lnrpc_SendRequest {
    init(paymentRequest: String, amount: Satoshi?, feeLimitPercent: Int?) {
        self.init()

        self.paymentRequest = paymentRequest
        if let amount = amount {
            self.amt = amount.int64
        }
        if let feeLimitPercent = feeLimitPercent {
            self.feeLimit = Lnrpc_FeeLimit(percent: feeLimitPercent)
        }
    }
}

extension Lnrpc_FeeLimit {
    init(percent: Int) {
        self.init()

        self.percent = Int64(percent)
    }
}

extension Lnrpc_CloseChannelRequest {
    init(channelPoint: ChannelPoint, force: Bool) {
        self.init()

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
        self.init()

        pubKey = destination
        amt = amount.int64
        useMissionControl = true
    }
}

// MARK: - Wallet

extension Lnrpc_InitWalletRequest {
    init(password: String, mnemonic: [String], channelBackup: ChannelBackup?, recoverWindow: Int) {
        self.init()

        if let passwordData = password.data(using: .utf8) {
            self.walletPassword = passwordData
        }
        if let channelBackup = channelBackup {
            var chanBackupSnapshot = Lnrpc_ChanBackupSnapshot()
            chanBackupSnapshot.multiChanBackup = Lnrpc_MultiChanBackup()
            chanBackupSnapshot.multiChanBackup.multiChanBackup = channelBackup.data

            self.channelBackups = chanBackupSnapshot
        }
        self.cipherSeedMnemonic = mnemonic
        self.recoveryWindow = Int32(recoverWindow)
    }
}

extension Lnrpc_UnlockWalletRequest {
    init(password: String) {
        self.init()

        if let passwordData = password.data(using: .utf8) {
            self.walletPassword = passwordData
        }
    }
}

extension Lnrpc_ListInvoiceRequest {
    init(reversed: Bool) {
        self.init()
        self.reversed = reversed
    }
}

extension Lnrpc_EstimateFeeRequest {
    init(address: BitcoinAddress, amount: Satoshi, confirmationTarget: Int) {
        self.init()
        self.addrToAmount = [address.string: amount.int64]
        self.targetConf = Int32(confirmationTarget)
    }
}
