//
//  Lightning
//
//  Created by Otto Suess on 05.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import ReactiveKit
import SwiftLnd

final class ConnectionStateUpdater: NSObject {
    enum State {
        case connecting
        case syncing
        case running
    }
    
    let state = Observable<ConnectionStateUpdater.State>(.connecting)
    private var connectionTimeoutTimer: Timer?
    private var syncingStartTime: Date?
    private var walletStateDisposable: Disposable?
    private let infoService: InfoService
    private weak var disconnectWalletDelegate: DisconnectWalletDelegate?
    
    init(infoService: InfoService, disconnectWalletDelegate: DisconnectWalletDelegate) {
        self.infoService = infoService
        self.disconnectWalletDelegate = disconnectWalletDelegate
        
        super.init()
    }
    
    func start() {
        bindLndState()
        
        connectionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            self?.connectionTimeoutTimer = nil
            self?.disconnectWalletDelegate?.disconnect()
        }
    }
    
    func stop() {
        walletStateDisposable?.dispose()
    }
    
    private func bindLndState() {
        walletStateDisposable = infoService.info
            .skip(first: 1)
            .map(stateForInfo)
            .filter(filterSyncing)
            .distinct()
            .feedNext(into: state)
            .observeNext { [weak self] _ in
                guard let self = self else { return }
                self.connectionTimeoutTimer?.invalidate()
                self.connectionTimeoutTimer = nil
            }
        
        walletStateDisposable?.dispose(in: reactive.bag)
    }
    
    private func stateForInfo(_ info: Info?) -> State {
        if let info = info {
            return info.isSyncedToChain ? .running : .syncing
        }
        return .connecting
    }
    
    // add 3 second debounce to syncing, so we don't switch to sync screen when the app is running and a new block is found.
    private func filterSyncing(newState: State) -> Bool {
        if state.value == .running && newState == .syncing {
            if let syncingStartTime = syncingStartTime {
                if syncingStartTime.addingTimeInterval(3) < Date() {
                    self.syncingStartTime = nil
                    return true
                }
            } else {
                syncingStartTime = Date()
            }
            return false
        }
        return true
    }
}
