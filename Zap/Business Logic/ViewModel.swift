//
//  Zap
//
//  Created by Otto Suess on 21.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

final class ViewModel: NSObject {
    
    private let api: LightningProtocol
    
    let info: Wallet
    
    // Balances
    let balance = Observable<Satoshi>(0)
    let channelBalance = Observable<Satoshi>(0)
    let totalBalance: Signal<Satoshi, NoError>
    
    // Transactions
    let onChainTransactions = Observable<[Transaction]>([])
    let payments = Observable<[Transaction]>([])
    let invoices = Observable<[Transaction]>([])
    
    // Channel
    let channels = Observable<[Channel]>([])
    let pendingChannels = Observable<[Channel]>([])
    
    let errorMessages = Observable<String?>(nil)

    var transactionMetadataUpdater: TransactionMetadataUpdater?
    
    init(api: LightningProtocol = LightningStream()) {
        self.api = api
        self.info = Wallet(api: api)
        
        Lnd.start()

        totalBalance = combineLatest(balance, channelBalance) { $0 + $1 }

        super.init()
        
        start()
        
        transactionMetadataUpdater = TransactionMetadataUpdater(viewModel: self, transactionMetadataStore: MemoryTransactionMetadataStore.instance)
        
//        WalletViewModel().unlock { [weak self] result in
//            if result.value != nil {
//                self?.start()
//            } else {
//                print("unlocking error")
//            }
//        }
    }
    
    private func start() {
        info.walletState
            .filter { $0 != .connecting }
            .distinct()
            .observeNext { [weak self] _ in
                self?.updateChannelBalance()
                self?.updateChannels()
                self?.updatePendingChannels()
                self?.updateWalletBalance()
                self?.updateTransactions()
            }
            .dispose(in: reactive.bag)
        
        api.subscribeChannelGraph { _ in

        }
    }
    
    
    private func updateWalletBalance() {
        api.walletBalance { [balance] result in
            balance.value = result.value ?? 0
        }
    }

    func updateTransactions() {
        api.transactions { [onChainTransactions] result in
            onChainTransactions.value = result.value ?? []
        }
        
        api.payments { [payments] result in
            payments.value = result.value ?? []
        }

        api.invoices { [invoices] result in
            invoices.value = result.value ?? []
        }
    }

    private func updateChannelBalance() {
        api.channelBalance { [channelBalance] result in
            channelBalance.value = result.value ?? 0
        }
    }
    
    func updateChannels() {
        api.channels { [channels] result in
            channels.value = result.value ?? []
        }
    }
    
    private func updatePendingChannels() {
        api.pendingChannels { [pendingChannels] result in
            pendingChannels.value = result.value ?? []
        }
    }
    
    func newAddress(callback: @escaping (Result<String>) -> Void) {
        api.newAddress(type: Settings.onChainRequestAddressType.value, callback: callback)
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, callback: callback)
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest, callback: @escaping (Bool) -> Void) {
        api.sendPayment(paymentRequest) { [weak self] _ in
            self?.updateChannelBalance()
            self?.updateTransactions()
            self?.updateChannels()
            callback(true)
        }
    }
    
    func openChannel(pubKey: String, host: String, amount: Satoshi, completion: @escaping () -> Void) {
        api.peers { [weak self, api] peers in
            if peers.value?.contains(where: { $0.pubKey == pubKey }) == true {
                self?.openConnectedChannel(pubKey: pubKey, amount: amount, completion: completion)
            } else {
                api.connect(pubKey: pubKey, host: host) {
                    guard $0.error != nil else { return }
                    self?.openConnectedChannel(pubKey: pubKey, amount: amount, completion: completion)
                }
            }
        }
    }
    
    private func openConnectedChannel(pubKey: String, amount: Satoshi, completion: @escaping () -> Void) {
        api.openChannel(pubKey: pubKey, amount: amount) { [weak self] _ in
            self?.updateChannelBalance()
            self?.updateChannels()
            self?.updatePendingChannels()
            completion()
        }
    }
    
    func closeChannel(channelPoint: String) {
        api.closeChannel(channelPoint: channelPoint) { [weak self] _ in
            self?.updateChannelBalance()
            self?.updateChannels()
            self?.updatePendingChannels()
        }
    }
    
    func sendCoins(address: String, amount: Satoshi, completion: @escaping () -> Void) {
        api.sendCoins(address: address, amount: amount) { _ in completion() }
    }
    
    func addInvoice(amount: Satoshi, memo: String?, callback: @escaping (Result<String>) -> Void) {
        api.addInvoice(amount: amount, memo: memo, callback: callback)
    }
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        api.nodeInfo(pubKey: pubKey, callback: callback)
    }
}
