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

enum WalletState {
    case connect
    case create
    case sync
    case wallet
}

final class ViewModel {
    private let api: Lightning
    
    let walletState: Observable<WalletState>
    
    // Info
    let bestHeaderDate = Observable<Date?>(nil)
    let blockChainHeight = Observable<Int?>(nil)
    let blockHeight = Observable(0)
    let isSyncedToChain = Observable(false)
    let alias = Observable<String?>(nil)
    
    // Balances
    let balance = Observable<Satoshi>(0)
    let channelBalance = Observable<Satoshi>(0)
    let totalBalance: Signal<Satoshi, NoError>
    
    // Transactions
    let onChainTransactions = Observable<[Transaction]>([])
    let payments = Observable<[Transaction]>([])
    
    // Channel
    let channels = Observable<[Channel]>([])
    let pendingChannels = Observable<[Channel]>([])
    
    let errorMessages = Observable<String?>(nil)

    var transactionMetadataUpdater: TransactionMetadataUpdater?
    
    static var didCreateWallet: Bool {
        get {
            return UserDefaults.Keys.didCreateWallet.get(defaultValue: false)
        }
        set {
            UserDefaults.Keys.didCreateWallet.set(newValue)
        }
    }
    
    init(api: Lightning = Lightning()) {
        self.api = api
        
        if ViewModel.didCreateWallet {
            walletState = Observable(.connect)
        } else {
            walletState = Observable(.create)
        }
        
        Lnd.instance.startLnd()

        totalBalance = combineLatest(balance, channelBalance) { $0 + $1 }

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
        api.walletBalance { [balance] result in
            balance.value = result.value ?? 0
        }
        
        api.transactions { [onChainTransactions] result in
            onChainTransactions.value = result.value ?? []
        }
        
        updateChannelBalance()
        updatePayments()
        updateChannels()
        updatePendingChannels()
        
        Scheduler.schedule(interval: 120, job: BlockChainHeightJob { [blockChainHeight] height in
            blockChainHeight.value = height
        })
        
        Scheduler.schedule(interval: 1, action: { [api, updateInfo] in
            api.info(callback: updateInfo)
        })
    }
    
    private func updateInfo(result: Result<Info>) {
        if let info = result.value {
            if !ViewModel.didCreateWallet {
                walletState.value = .create
            } else if !info.isSyncedToChain {
                walletState.value = .sync
            } else {
                walletState.value = .wallet
            }
            
            blockHeight.value = info.blockHeight
            isSyncedToChain.value = info.isSyncedToChain
            alias.value = info.alias
            bestHeaderDate.value = info.bestHeaderDate
        } else {
            walletState.value = ViewModel.didCreateWallet ? .connect : .create
        }
    }
    
    private func updateChannelBalance() {
        api.channelBalance { [channelBalance] result in
            channelBalance.value = result.value ?? 0
        }
    }
    
    private func updatePayments() {
        api.payments { [payments] result in
            payments.value = result.value ?? []
        }
    }
    
    private func updateChannels() {
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
        api.newAddress(callback: callback)
    }
    
    func decodePaymentRequest(_ paymentRequest: String, callback: @escaping (Result<PaymentRequest>) -> Void) {
        api.decodePaymentRequest(paymentRequest, callback: callback)
    }
    
    func sendPayment(_ paymentRequest: PaymentRequest) {
        api.sendPayment(paymentRequest) { [weak self] _ in
            self?.updateChannelBalance()
            self?.updatePayments()
            self?.updateChannels()
        }
    }
    
    func openChannel(pubKey: String, amount: Satoshi) {
        api.openChannel(pubKey: pubKey, amount: amount) { [weak self] _ in
            self?.updateChannelBalance()
            self?.updateChannels()
            self?.updatePendingChannels()
        }
    }
    
    func closeChannel(channelPoint: String) {
        api.closeChannel(channelPoint: channelPoint) { [weak self] _ in
            self?.updateChannelBalance()
            self?.updateChannels()
            self?.updatePendingChannels()
        }
    }
    
    func sendCoins(address: String, amount: Satoshi) {
        api.sendCoins(address: address, amount: amount) { _ in }
    }
    
    func addInvoice(amount: Satoshi, memo: String?, callback: @escaping (Result<String>) -> Void) {
        api.addInvoice(amount: amount, memo: memo, callback: callback)
    }
    
    func connect(pubKey: String, host: String, callback: @escaping (Result<Void>) -> Void) {
        api.connect(pubKey: pubKey, host: host, callback: callback)
    }
    
    func nodeInfo(pubKey: String, callback: @escaping (Result<NodeInfo>) -> Void) {
        api.nodeInfo(pubKey: pubKey, callback: callback)
    }
}
