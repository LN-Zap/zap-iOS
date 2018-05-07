//
//  Zap
//
//  Created by Otto Suess on 03.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

extension Lnrpc_Invoice {
    init(amount: Satoshi?, memo: String?) {
        self.init()
        if let memo = memo {
            self.memo = memo
        }
        if let amount = amount {
            value = Int64(truncating: amount)
        }
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
    init(type: AddressType) {
        self.type = type
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
        if let pubKey = pubKey.hexadecimal() {
            nodePubkey = pubKey
        }
        localFundingAmount = Int64(truncating: amount)
        `private` = true
    }
}

extension Lnrpc_SendCoinsRequest {
    init(address: String, amount: Satoshi) {
        self.addr = address
        self.amount = Int64(truncating: amount)
    }
}

extension Lnrpc_SendRequest {
    init(paymentRequest: String) {
        self.paymentRequest = paymentRequest
    }
}

extension Lnrpc_CloseChannelRequest {
    init?(channelPoint: String) {
        let channelPointParts = channelPoint.components(separatedBy: ":")
        guard let outputIndex = UInt32(channelPointParts[1]) else { return nil }
        
        self.channelPoint = Lnrpc_ChannelPoint()
        self.channelPoint.outputIndex = outputIndex
        if let fundingTxidBytes = channelPointParts[0].hexEndianSwap().hexadecimal() {
            self.channelPoint.fundingTxidBytes = fundingTxidBytes
        }
        self.force = true
    }
}
