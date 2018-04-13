//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

protocol LightningProtocol {
    func info(callback: @escaping (Result<Info>) -> Void)
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void)
    func newAddress(callback: @escaping (Result<String>) -> Void)
    func walletBalance(callback: @escaping (Result<Satoshi>) -> Void)
    func channelBalance(callback: @escaping (Result<Satoshi>) -> Void)
    func transactions(callback: @escaping (Result<[Transaction]>) -> Void)
    func subscribeTransactions(callback: @escaping (Result<Transaction>) -> Void)
    func payments(callback: @escaping (Result<[Transaction]>) -> Void)
    func channels(callback: @escaping (Result<[Channel]>) -> Void)
    func pendingChannels(callback: @escaping (Result<[Channel]>) -> Void)
    func connect(pubKey: String, host: String, callback: @escaping (Result<Void>) -> Void)
    func openChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<OpenStatusUpdate>) -> Void)
    func closeChannel(channelPoint: String, callback: @escaping (Result<CloseStatusUpdate>) -> Void)
    func sendCoins(address: String, amount: Satoshi, callback: @escaping (Result<String>) -> Void)
    func peers(callback: @escaping (Result<[Peer]>) -> Void)
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void)
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Result<Data>) -> Void)
    func addInvoice(amount: Satoshi, memo: String?, callback: @escaping (Result<String>) -> Void)
}
