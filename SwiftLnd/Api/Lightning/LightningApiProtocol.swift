//
//  Zap
//
//  Created by Otto Suess on 13.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public protocol LightningApiProtocol {
    func info(completion: @escaping (Result<Info, LndApiError>) -> Void)
    
    // Channels
    func openChannel(pubKey: String, amount: Satoshi, completion: @escaping (Result<ChannelPoint, LndApiError>) -> Void)
    func closeChannel(channelPoint: ChannelPoint, force: Bool, completion: @escaping (Result<CloseStatusUpdate, LndApiError>) -> Void)
    func channelBalance(completion: @escaping (Result<Satoshi, LndApiError>) -> Void)
    func pendingChannels(completion: @escaping (Result<[Channel], LndApiError>) -> Void)
    func channels(completion: @escaping (Result<[Channel], LndApiError>) -> Void)
    func closedChannels(completion: @escaping (Result<[ChannelCloseSummary], LndApiError>) -> Void)
    func subscribeChannelGraph(completion: @escaping (Result<GraphTopologyUpdate, LndApiError>) -> Void)

    // On-chain
    func sendCoins(address: BitcoinAddress, amount: Satoshi, completion: @escaping (Result<String, LndApiError>) -> Void)
    func transactions(completion: @escaping (Result<[Transaction], LndApiError>) -> Void)
    func subscribeTransactions(completion: @escaping (Result<Transaction, LndApiError>) -> Void)

    // Payments
    func decodePaymentRequest(_ paymentRequest: String, completion: @escaping (Result<PaymentRequest, LndApiError>) -> Void)
    func payments(completion: @escaping (Result<[Payment], LndApiError>) -> Void)
    func sendPayment(_ paymentRequest: PaymentRequest, amount: Satoshi?, completion: @escaping (Result<Payment, LndApiError>) -> Void)
    func addInvoice(amount: Satoshi?, memo: String?, completion: @escaping (Result<String, LndApiError>) -> Void)
    func invoices(completion: @escaping (Result<[Invoice], LndApiError>) -> Void)
    func subscribeInvoices(completion: @escaping (Result<Invoice, LndApiError>) -> Void)
    func routes(destination: String, amount: Satoshi, completion: @escaping (Result<[Route], LndApiError>) -> Void)
    
    // Peers
    func connect(pubKey: String, host: String, completion: @escaping (Result<Success, LndApiError>) -> Void)
    func nodeInfo(pubKey: String, completion: @escaping (Result<NodeInfo, LndApiError>) -> Void)
    func peers(completion: @escaping (Result<[Peer], LndApiError>) -> Void)
    
    // Wallet
    func newAddress(type: OnChainRequestAddressType, completion: @escaping (Result<BitcoinAddress, LndApiError>) -> Void)
    func walletBalance(completion: @escaping (Result<Satoshi, LndApiError>) -> Void)
}
