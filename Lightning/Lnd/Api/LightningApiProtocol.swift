//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

protocol LightningApiProtocol {
    func info(completion: @escaping (Result<Info>) -> Void)
    
    // Channels
    func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint>) -> Void)
    func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate>) -> Void)
    func channelBalance(completion: @escaping (Result<Satoshi>) -> Void)
    func pendingChannels(completion: @escaping (Result<[Channel]>) -> Void)
    func channels(completion: @escaping (Result<[Channel]>) -> Void)
    func closedChannels(completion: @escaping (Result<[ChannelCloseSummary]>) -> Void)
    func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate>) -> Void)

    // On-chain
    func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<OnChainUnconfirmedTransaction>) -> Void)
    func transactions(completion: @escaping (Result<[Transaction]>) -> Void)
    func subscribeTransactions(completion: @escaping (Result<Transaction>) -> Void)

    // Payments
    func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest>) -> Void)
    func payments(completion: @escaping (Result<[Transaction]>) -> Void)
    func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<LightningPayment>) -> Void)
    func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String>) -> Void)
    func invoices(completion: @escaping (Result<[Transaction]>) -> Void)
    func subscribeInvoices(completion: @escaping (Result<Transaction>) -> Void)

    // Peers
    func connect(pubKey: String, host: String, completion: @escaping (Result<Success>) -> Void)
    func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo>) -> Void)
    func peers(completion: @escaping (Result<[Peer]>) -> Void)
    
    // Wallet
    func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress>) -> Void)
    func walletBalance(completion: @escaping (Result<Satoshi>) -> Void)
}
