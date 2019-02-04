//
//  Lightning
//
//  Created by Otto Suess on 05.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

public final class ConnectionStateService: NSObject {
    public enum State {
        case connecting
        case syncing
        case running
    }
    
    public let state = Observable<State>(.connecting)
    private var connectionTimeoutTimer: Timer?
    private var syncingStartTime: Date?
    private var walletStateDisposable: Disposable?
    private let infoService: InfoService

    init(infoService: InfoService) {
        self.infoService = infoService
        
        super.init()
        
        bindLndState()
    }
    
    func start() {
        connectionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.connectionTimeoutTimer = nil
        }
    }
    
    func stop() {
        walletStateDisposable?.dispose()
    }
    
    private func bindLndState() {
        walletStateDisposable = infoService.walletState
            .skip(first: 1)
            .filter(filterSyncing)
            .distinct()
            .map(stateForInfoState)
            .feedNext(into: state)
            .observeNext { [weak self] _ in
                guard let self = self else { return }
                self.connectionTimeoutTimer?.invalidate()
                self.connectionTimeoutTimer = nil
            }
        
        walletStateDisposable?.dispose(in: reactive.bag)
    }
    
    private func stateForInfoState(_ state: InfoService.State) -> State {
        switch state {
        case .connecting:
            return .connecting
        case .syncing:
            return .syncing
        case .running:
            return .running
        }
    }
    
    // add 3 second debounce to syncing, so we don't switch to sync screen when the app is running and a new block is found.
    private func filterSyncing(newState: InfoService.State) -> Bool {
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
