//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

protocol LightningApiProtocol {
    func info(callback: @escaping (Result<Info>) -> Void)
    
    // Channels
    func openChannel(pubKey: String, amount: Satoshi, callback: @escaping (Result<ChannelPoint>) -> Void)
    func closeChannel(channelPoint: ChannelPoint, force: Bool, callback: @escaping (Result<CloseStatusUpdate>) -> Void)
    func channelBalance(callback: @escaping (Result<Satoshi>) -> Void)
    func pendingChannels(callback: @escaping (Result<[Channel]>) -> Void)
    func channels(callback: @escaping (Result<[Channel]>) -> Void)
    func closedChannels(callback: @escaping (Result<[ChannelCloseSummary]>) -> Void)
    func subscribeChannelGraph(callback: @escaping (Result<GraphTopologyUpdate>) -> Void)

    // On-chain
    func sendCoins(address: String, amount: Satoshi, callback: @escaping (Result<OnChainUnconfirmedTransaction>) -> Void)
    func transactions(callback: @escaping (Result<[Transaction]>) -> Void)
    func subscribeTransactions(callback: @escaping (Result<Transaction>) -> Void)

    // Payments
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void)
    func payments(callback: @escaping (Result<[Transaction]>) -> Void)
    func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, callback: @escaping (Result<Data>) -> Void)
    func addInvoice(amount: Satoshi?, memo: String?, callback: @escaping (Result<String>) -> Void)
    func invoices(callback: @escaping (Result<[Transaction]>) -> Void)
    func subscribeInvoices(callback: @escaping (Result<Transaction>) -> Void)

    // Peers
    func connect(pubKey: String, host: String, callback: @escaping (Result<Success>) -> Void)
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void)
    func peers(callback: @escaping (Result<[Peer]>) -> Void)
    
    // Wallet
    func newAddress(type: OnChainRequestAddressType, callback: @escaping (Result<String>) -> Void)
    func walletBalance(callback: @escaping (Result<Satoshi>) -> Void)
}
