//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public protocol LightningApiProtocol {
    func info(completion: @escaping Handler<Info>)

    // Channels
    func openChannel(pubKey: String, amount: Satoshi, completion: @escaping Handler<ChannelPoint>)
    func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping Handler<CloseStatusUpdate>)
    func channelBalance(completion: @escaping Handler<ChannelBalance>)
    func pendingChannels(completion: @escaping Handler<[Channel]>)
    func channels(completion: @escaping Handler<[Channel]>)
    func closedChannels(completion: @escaping Handler<[ChannelCloseSummary]>)
    func subscribeChannelGraph(completion: @escaping Handler<GraphTopologyUpdate>)
    func subscribeChannelEvents(completion: @escaping Handler<ChannelEventUpdate>)

    // On-chain
    func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping Handler<String>)
    func transactions(completion: @escaping Handler<[Transaction]>)
    func subscribeTransactions(completion: @escaping Handler<Transaction>)

    // Payments
    func decodePaymentRequest(_ paymentRequest: String, completion: @escaping Handler<PaymentRequest>)
    func payments(completion: @escaping Handler<[Payment]>)
    func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping Handler<Payment>)
    func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping Handler<String>)
    func invoices(completion: @escaping Handler<[Invoice]>)
    func subscribeInvoices(completion: @escaping Handler<Invoice>)
    func routes(destination: String, amount: Satoshi, completion: @escaping Handler<[Route]>)

    // Peers
    func connect(pubKey: String, host: String, completion: @escaping Handler<Success>)
    func nodeInfo(pubKey: String, completion: @escaping Handler<NodeInfo>)
    func peers(completion: @escaping Handler<[Peer]>)

    // Wallet
    func newAddress(type: OnChainRequestAddressType, completion: @escaping Handler<BitcoinAddress>)
    func walletBalance(completion: @escaping Handler<WalletBalance>)
}
